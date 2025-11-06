; RUN: not opt -passes=verify < %s 2>&1 | FileCheck %s

declare void @g()

define void @test_ptrauth_bundle(i64 %arg.64, ptr %arg.ptr, ptr %ok) {

; CHECK: Multiple ptrauth operand bundles on a function call
; CHECK-NEXT: call void %arg.ptr() [ "ptrauth"(i64 42, i64 100), "ptrauth"(i64 42, i64 %arg.64) ]
  call void %arg.ptr() [ "ptrauth"(i64 42, i64 100), "ptrauth"(i64 42, i64 %arg.64) ]

; CHECK: Direct call cannot have a ptrauth bundle
; CHECK-NEXT: call void @g() [ "ptrauth"(i64 42, i64 120) ]
  call void @g() [ "ptrauth"(i64 42, i64 120) ]

; CHECK-NOT: call void %ok()
  call void %ok() [ "ptrauth"(i32 42, i64 120) ]   ; OK
  call void %ok() [ "ptrauth"(i32 42, i64 %arg.64) ] ; OK
  call void %ok() [ "ptrauth"(i64 %arg.64, i64 123) ] ; OK
  call void %ok() [ "ptrauth"(i64 %arg.64, i64 123, i64 %arg.64, i64 42) ] ; OK

; CHECK: Expected non-empty ptrauth bundle
; CHECK-NEXT: call void %arg.ptr() [ "ptrauth"() ]
  call void %arg.ptr() [ "ptrauth"() ]

; CHECK: Ptrauth bundle must only contain i64 operands
; CHECK-NEXT: call void %arg.ptr() [ "ptrauth"(i64 42, i32 120) ]
  call void %arg.ptr() [ "ptrauth"(i64 42, i32 120) ]

; CHECK: Ptrauth bundle must only contain i64 operands
; CHECK-NEXT: call void %arg.ptr() [ "ptrauth"(i32 42, i64 120, i64 123) ]
  call void %arg.ptr() [ "ptrauth"(i32 42, i64 120, i64 123) ]

; CHECK: Ptrauth bundle must only contain i64 operands
; CHECK-NEXT: call void %arg.ptr() [ "ptrauth"(i64 42, i64 120, i32 123) ]
  call void %arg.ptr() [ "ptrauth"(i64 42, i64 120, i32 123) ]

; Note that for compatibility reasons the first operand (originally, "the key ID")
; might be auto-upgraded to i64:
;
; CHECK-NOT:  call void %ok()
  call void %ok() [ "ptrauth"(i32 42, i64 120) ]

; CHECK: Expected exactly one ptrauth bundle
; CHECK-NEXT: call i64 @llvm.ptrauth.auth(i64 0)
; CHECK: Expected exactly one ptrauth bundle
; CHECK-NEXT: call i64 @llvm.ptrauth.auth(i64 0) [ "ptrauth"(i64 42, i64 120), "ptrauth"(i64 42, i64 120) ]
; CHECK-NOT:  @llvm.ptrauth.auth
  call i64 @llvm.ptrauth.auth(i64 0)
  call i64 @llvm.ptrauth.auth(i64 0) [ "ptrauth"(i64 42, i64 120), "ptrauth"(i64 42, i64 120) ]
  call i64 @llvm.ptrauth.auth(i64 0) [ "ptrauth"(i64 42, i64 120) ]
  call i64 @llvm.ptrauth.auth(i64 0) [ "ptrauth"(i64 %arg.64) ]

; CHECK: Expected exactly one ptrauth bundle
; CHECK-NEXT: call i64 @llvm.ptrauth.sign(i64 0)
; CHECK: Expected exactly one ptrauth bundle
; CHECK-NEXT: call i64 @llvm.ptrauth.sign(i64 0) [ "ptrauth"(i64 42, i64 120), "ptrauth"(i64 42, i64 120) ]
; CHECK-NOT:  @llvm.ptrauth.sign
  call i64 @llvm.ptrauth.sign(i64 0)
  call i64 @llvm.ptrauth.sign(i64 0) [ "ptrauth"(i64 42, i64 120), "ptrauth"(i64 42, i64 120) ]
  call i64 @llvm.ptrauth.sign(i64 0) [ "ptrauth"(i64 42, i64 120) ]
  call i64 @llvm.ptrauth.sign(i64 0) [ "ptrauth"(i64 %arg.64) ]

; CHECK: Expected exactly two ptrauth bundles
; CHECK-NEXT: call i64 @llvm.ptrauth.resign(i64 0)
; CHECK: Expected exactly two ptrauth bundles
; CHECK-NEXT: call i64 @llvm.ptrauth.resign(i64 0) [ "ptrauth"(i64 42, i64 120) ]
; CHECK-NOT:  @llvm.ptrauth.resign
  call i64 @llvm.ptrauth.resign(i64 0)
  call i64 @llvm.ptrauth.resign(i64 0) [ "ptrauth"(i64 42, i64 120) ]
  call i64 @llvm.ptrauth.resign(i64 0) [ "ptrauth"(i64 42, i64 120), "ptrauth"(i64 42, i64 120) ]
  call i64 @llvm.ptrauth.resign(i64 0) [ "ptrauth"(i64 %arg.64), "ptrauth"(i64 42, i64 120, i64 0, i64 123) ]

; CHECK: Expected exactly one ptrauth bundle
; CHECK-NEXT: call i64 @llvm.ptrauth.strip(i64 0)
; CHECK: Expected exactly one ptrauth bundle
; CHECK-NEXT: call i64 @llvm.ptrauth.strip(i64 0) [ "ptrauth"(i64 42, i64 120), "ptrauth"(i64 42, i64 120) ]
; CHECK-NOT:  @llvm.ptrauth.strip
  call i64 @llvm.ptrauth.strip(i64 0)
  call i64 @llvm.ptrauth.strip(i64 0) [ "ptrauth"(i64 42, i64 120), "ptrauth"(i64 42, i64 120) ]
  call i64 @llvm.ptrauth.strip(i64 0) [ "ptrauth"(i64 42, i64 120) ]
  call i64 @llvm.ptrauth.strip(i64 0) [ "ptrauth"(i64 %arg.64) ]

; CHECK: Unexpected ptrauth bundle on intrinsic call
; CHECK-NEXT: call i64 @llvm.ptrauth.sign.generic(i64 0, i64 42) [ "ptrauth"(i64 42, i64 120) ]
  call i64 @llvm.ptrauth.sign.generic(i64 0, i64 42) [ "ptrauth"(i64 42, i64 120) ]

  ret void
}
