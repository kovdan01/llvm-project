; RUN: split-file %s %t

;--- store.ll
; RUN: not opt -passes=verify -S < %t/store.ll 2>&1 | FileCheck --check-prefix=STORE %s

; STORE:      Cannot upgrade all uses of @llvm.ptrauth.blend in function:
; STORE-NEXT: define void @test(ptr %p, i64 %addr) {
; STORE-NEXT:   %disc = call i64 @llvm.ptrauth.blend(i64 %addr, i64 42)
; STORE-NEXT:   store i64 %disc, ptr %p, align 4
; STORE-NEXT:   ret void
; STORE-NEXT: }
; STORE-NEXT: LLVM ERROR: Cannot upgrade some uses of @llvm.ptrauth.blend().

define void @test(ptr %p, i64 %addr) {
  %disc = call i64 @llvm.ptrauth.blend(i64 %addr, i64 42)
  store i64 %disc, ptr %p
  ret void
}

;--- arith.ll
; RUN: not opt -passes=verify -S < %t/arith.ll 2>&1 | FileCheck --check-prefix=ARITH %s

; ARITH:      Cannot upgrade all uses of @llvm.ptrauth.blend in function:
; ARITH-NEXT: define void @test(ptr %p, i64 %addr) {
; ARITH-NEXT:   %disc = call i64 @llvm.ptrauth.blend(i64 %addr, i64 42)
; ARITH-NEXT:   %tmp = add i64 %disc, 42
; ARITH-NEXT:   ret void
; ARITH-NEXT: }
; ARITH-NEXT: LLVM ERROR: Cannot upgrade some uses of @llvm.ptrauth.blend().

define void @test(ptr %p, i64 %addr) {
  %disc = call i64 @llvm.ptrauth.blend(i64 %addr, i64 42)
  %tmp = add i64 %disc, 42
  ret void
}

;--- indirect-one-arg.ll
; RUN: not opt -passes=verify -S < %t/indirect-one-arg.ll 2>&1 | FileCheck --check-prefix=INDIRECT-ONE-ARG %s

; INDIRECT-ONE-ARG:      Cannot upgrade all uses of @llvm.ptrauth.blend in function:
; INDIRECT-ONE-ARG-NEXT: define void @test(ptr %some_fn, i64 %addr) {
; INDIRECT-ONE-ARG-NEXT:   %disc = call i64 @llvm.ptrauth.blend(i64 %addr, i64 42)
; INDIRECT-ONE-ARG-NEXT:   call void %some_fn(i64 %disc)
; INDIRECT-ONE-ARG-NEXT:   ret void
; INDIRECT-ONE-ARG-NEXT: }
; INDIRECT-ONE-ARG-NEXT: LLVM ERROR: Cannot upgrade some uses of @llvm.ptrauth.blend().

define void @test(ptr %some_fn, i64 %addr) {
  %disc = call i64 @llvm.ptrauth.blend(i64 %addr, i64 42)
  call void %some_fn(i64 %disc)
  ret void
}

;--- direct-one-arg.ll
; RUN: not opt -passes=verify -S < %t/direct-one-arg.ll 2>&1 | FileCheck --check-prefix=DIRECT-ONE-ARG %s

; DIRECT-ONE-ARG:      Cannot upgrade all uses of @llvm.ptrauth.blend in function:
; DIRECT-ONE-ARG-NEXT: define void @test(i64 %addr) {
; DIRECT-ONE-ARG-NEXT:   %disc = call i64 @llvm.ptrauth.blend(i64 %addr, i64 42)
; DIRECT-ONE-ARG-NEXT:   call void @some_fn(i64 %disc)
; DIRECT-ONE-ARG-NEXT:   ret void
; DIRECT-ONE-ARG-NEXT: }
; DIRECT-ONE-ARG-NEXT: LLVM ERROR: Cannot upgrade some uses of @llvm.ptrauth.blend().

declare void @some_fn(i64 %0)

define void @test(i64 %addr) {
  %disc = call i64 @llvm.ptrauth.blend(i64 %addr, i64 42)
  call void @some_fn(i64 %disc)
  ret void
}

; During the upgrade, it is not always possible to directly check whether
; a call site is an intrinsic call and if it is, which intrinsic is called.
; Though, these errors can be caught indirectly.
; In the below test cases, auth_like_fn has the same arguments as the old
; version of @llvm.ptrauth.auth intrinsic.

;--- indirect-three-args.ll
; RUN: not opt -passes=verify -S < %t/indirect-three-args.ll 2>&1 | FileCheck --check-prefix=INDIRECT-THREE-ARGS %s

; Invalid call to %auth_like_fn is detected, because intrinsics are never
; called indirectly.

; INDIRECT-THREE-ARGS:      Cannot upgrade all uses of @llvm.ptrauth.blend in function:
; INDIRECT-THREE-ARGS-NEXT: define void @test(i64 %p, ptr %auth_like_fn, i64 %addr) {
; INDIRECT-THREE-ARGS-NEXT:   %disc = call i64 @llvm.ptrauth.blend(i64 %addr, i64 42)
; INDIRECT-THREE-ARGS-NEXT:   call void %auth_like_fn(i64 %p, i32 1, i64 %disc)
; INDIRECT-THREE-ARGS-NEXT:   ret void
; INDIRECT-THREE-ARGS-NEXT: }
; INDIRECT-THREE-ARGS-NEXT: LLVM ERROR: Cannot upgrade some uses of @llvm.ptrauth.blend().

define void @test(i64 %p, ptr %auth_like_fn, i64 %addr) {
  %disc = call i64 @llvm.ptrauth.blend(i64 %addr, i64 42)
  call void %auth_like_fn(i64 %p, i32 1, i64 %disc)
  ret void
}

;--- direct-three-args.ll
; RUN: not opt -passes=verify -S < %t/direct-three-args.ll 2>&1 | FileCheck --check-prefix=DIRECT-THREE-ARGS %s

; Invalid call to @auth_like_fn is formally upgraded as if it were an intrinsic
; call, but is caught by the verifier later, as regular function calls with
; "ptrauth" operand bundles must be indirect.

; DIRECT-THREE-ARGS:      Direct call cannot have a ptrauth bundle
; DIRECT-THREE-ARGS-NEXT:   call void @auth_like_fn(i64 %p, i32 0, i64 0) [ "ptrauth"(i64 1, i64 %addr, i64 42) ]
; DIRECT-THREE-ARGS-NEXT: error: input module is broken!

declare void @auth_like_fn(i64 %0, i32 %1, i64 %2)

define void @test(i64 %p, i64 %addr) {
  %disc = call i64 @llvm.ptrauth.blend(i64 %addr, i64 42)
  call void @auth_like_fn(i64 %p, i32 1, i64 %disc)
  ret void
}

;--- wrong-intrinsic-with-ptrauth-bundle.ll
; RUN: not opt -passes=verify -S < %t/wrong-intrinsic-with-ptrauth-bundle.ll 2>&1 | FileCheck --check-prefix=WRONG-INTRINSIC-WITH-PTRAUTH-BUNDLE %s

; This test case does not involve auto-upgrading, but it shows the behavior of
; the IR verifier if any unrelated intrinsic would be formally auto-upgraded.

; WRONG-INTRINSIC-WITH-PTRAUTH-BUNDLE:      Unexpected ptrauth bundle on intrinsic call
; WRONG-INTRINSIC-WITH-PTRAUTH-BUNDLE-NEXT:   %1 = call i64 @llvm.ptrauth.sign.generic(i64 %p, i64 0) [ "ptrauth"(i64 1, i64 %addr, i64 42) ]
; WRONG-INTRINSIC-WITH-PTRAUTH-BUNDLE-NEXT: /data/ast/llvm-project/build/bin/opt: -: error: input module is broken!

define void @test(i64 %p, ptr %auth_like_fn, i64 %addr) {
  %disc = call i64 @llvm.ptrauth.blend(i64 %addr, i64 42)
  ; The below call uses the new-style all-i64 ptrauth bundle.
  call i64 @llvm.ptrauth.sign.generic(i64 %p, i64 0) [ "ptrauth"(i64 1, i64 %disc) ]
  ret void
}

;--- wrong-position-in-bundle.ll
; RUN: not opt -passes=verify -S < %t/wrong-position-in-bundle.ll 2>&1 | FileCheck --check-prefix=WRONG-POSITION-IN-BUNDLE %s

; WRONG-POSITION-IN-BUNDLE:      Cannot upgrade all uses of @llvm.ptrauth.blend in function:
; WRONG-POSITION-IN-BUNDLE-NEXT: define void @test(i64 %p, i64 %addr) {
; WRONG-POSITION-IN-BUNDLE-NEXT:   %disc = call i64 @llvm.ptrauth.blend(i64 %addr, i64 42)
; WRONG-POSITION-IN-BUNDLE-NEXT:   %1 = call i64 @llvm.ptrauth.auth(i64 %p) [ "ptrauth"(i64 %disc, i64 1) ]
; WRONG-POSITION-IN-BUNDLE-NEXT:   ret void
; WRONG-POSITION-IN-BUNDLE-NEXT: }
; WRONG-POSITION-IN-BUNDLE-NEXT: LLVM ERROR: Cannot upgrade some uses of @llvm.ptrauth.blend().

define void @test(i64 %p, i64 %addr) {
  %disc = call i64 @llvm.ptrauth.blend(i64 %addr, i64 42)
  call i64 @llvm.ptrauth.auth(i64 %p, i64 %disc, i64 1)
  ret void
}

;--- both-positions-in-bundle.ll
; RUN: not opt -passes=verify -S < %t/both-positions-in-bundle.ll 2>&1 | FileCheck --check-prefix=BOTH-POSITIONS-IN-BUNDLE %s

; BOTH-POSITIONS-IN-BUNDLE:      Cannot upgrade all uses of @llvm.ptrauth.blend in function:
; BOTH-POSITIONS-IN-BUNDLE-NEXT: define void @test(i64 %p, i64 %addr) {
; BOTH-POSITIONS-IN-BUNDLE-NEXT:   %disc = call i64 @llvm.ptrauth.blend(i64 %addr, i64 42)
; BOTH-POSITIONS-IN-BUNDLE-NEXT:   %1 = call i64 @llvm.ptrauth.auth(i64 %p) [ "ptrauth"(i64 %disc, i64 %addr, i64 42) ]
; BOTH-POSITIONS-IN-BUNDLE-NEXT:   ret void
; BOTH-POSITIONS-IN-BUNDLE-NEXT: }
; BOTH-POSITIONS-IN-BUNDLE-NEXT: LLVM ERROR: Cannot upgrade some uses of @llvm.ptrauth.blend().

define void @test(i64 %p, i64 %addr) {
  %disc = call i64 @llvm.ptrauth.blend(i64 %addr, i64 42)
  call i64 @llvm.ptrauth.auth(i64 %p, i64 %disc, i64 %disc)
  ret void
}
