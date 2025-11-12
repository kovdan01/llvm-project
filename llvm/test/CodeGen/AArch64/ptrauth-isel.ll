; RUN: llc < %s -mtriple arm64e-apple-darwin             -verify-machineinstrs -stop-after=finalize-isel -global-isel=0 \
; RUN:     | FileCheck %s --check-prefixes=CHECK,DARWIN --implicit-check-not=name: --implicit-check-not=MOVKXi
; RUN: llc < %s -mtriple arm64e-apple-darwin             -verify-machineinstrs -stop-after=finalize-isel -global-isel=1 -global-isel-abort=1 \
; RUN:     | FileCheck %s --check-prefixes=CHECK,DARWIN --implicit-check-not=name: --implicit-check-not=MOVKXi
; RUN: llc < %s -mtriple aarch64-linux-gnu -mattr=+pauth -verify-machineinstrs -stop-after=finalize-isel -global-isel=0 \
; RUN:     | FileCheck %s --check-prefixes=CHECK,ELF --implicit-check-not=name: --implicit-check-not=MOVKXi
; RUN: llc < %s -mtriple aarch64-linux-gnu -mattr=+pauth -verify-machineinstrs -stop-after=finalize-isel -global-isel=1 -global-isel-abort=1 \
; RUN:     | FileCheck %s --check-prefixes=CHECK,ELF --implicit-check-not=name: --implicit-check-not=MOVKXi

; Check MIR produced by the instruction selector to validate properties that
; cannot be reliably tested by only inspecting the final asm output.

@discvar = dso_local global i64 0

; Make sure zero address modifier is translated directly into a $noreg operand
; at the MIR level instead of a virtual register containing zero value.
;
; All relevant intrinsics are checked because some are selected by TableGen
; patterns and some other are selected by C++ code.

define i64 @pac_no_addr_modif_optimized(i64 %addr) {
  ; CHECK-LABEL: name: pac_no_addr_modif_optimized
  ; CHECK:         {{.*}} = PAC {{[^,]+}}, 2, 42, $noreg, implicit-def dead $x16, implicit-def dead $x17
  ; CHECK:         RET_ReallyLR implicit $x0
entry:
  %signed = call i64 @llvm.ptrauth.sign(i64 %addr) [ "ptrauth"(i64 2, i64 42, i64 0) ]
  ret i64 %signed
}

define i64 @pac_no_addr_modif_not_optimized(i64 %addr) noinline optnone {
  ; CHECK-LABEL: name: pac_no_addr_modif_not_optimized
  ; CHECK:         {{.*}} = PAC {{[^,]+}}, 2, 42, $noreg, implicit-def dead $x16, implicit-def dead $x17
  ; CHECK:         RET_ReallyLR implicit $x0
entry:
  %signed = call i64 @llvm.ptrauth.sign(i64 %addr) [ "ptrauth"(i64 2, i64 42, i64 0) ]
  ret i64 %signed
}

define i64 @aut_no_addr_modif_optimized(i64 %addr) {
  ; CHECK-LABEL: name: aut_no_addr_modif_optimized
  ; DARWIN:        AUTx16x17 2, 42, $noreg, implicit-def $x16, implicit-def {{(dead )?}}$x17, implicit-def dead $nzcv, implicit $x16
  ; ELF:           {{.*}} = AUTxMxN {{[^,]+}}, 2, 42, $noreg, implicit-def dead $nzcv
  ; CHECK:         RET_ReallyLR implicit $x0
entry:
  %signed = call i64 @llvm.ptrauth.auth(i64 %addr) [ "ptrauth"(i64 2, i64 42, i64 0) ]
  ret i64 %signed
}

define i64 @aut_no_addr_modif_not_optimized(i64 %addr) noinline optnone {
  ; CHECK-LABEL: name: aut_no_addr_modif_not_optimized
  ; DARWIN:        AUTx16x17 2, 42, $noreg, implicit-def $x16, implicit-def {{(dead )?}}$x17, implicit-def dead $nzcv, implicit $x16
  ; ELF:           {{.*}} = AUTxMxN {{[^,]+}}, 2, 42, $noreg, implicit-def dead $nzcv
  ; CHECK:         RET_ReallyLR implicit $x0
entry:
  %signed = call i64 @llvm.ptrauth.auth(i64 %addr) [ "ptrauth"(i64 2, i64 42, i64 0) ]
  ret i64 %signed
}

define i64 @resign_no_addr_modif_optimized(i64 %addr) {
  ; CHECK-LABEL: name: resign_no_addr_modif_optimized
  ; CHECK:         AUTPAC 2, 42, $noreg, 2, 123, $noreg, implicit-def $x16, implicit-def {{(dead )?}}$x17, implicit-def dead $nzcv, implicit $x16
  ; CHECK:         RET_ReallyLR implicit $x0
entry:
  %signed = call i64 @llvm.ptrauth.resign(i64 %addr) [ "ptrauth"(i64 2, i64 42, i64 0), "ptrauth"(i64 2, i64 123, i64 0) ]
  ret i64 %signed
}

define i64 @resign_no_addr_modif_not_optimized(i64 %addr) noinline optnone {
  ; CHECK-LABEL: name: resign_no_addr_modif_not_optimized
  ; CHECK:         AUTPAC 2, 42, $noreg, 2, 123, $noreg, implicit-def $x16, implicit-def {{(dead )?}}$x17, implicit-def dead $nzcv, implicit $x16
  ; CHECK:         RET_ReallyLR implicit $x0
entry:
  %signed = call i64 @llvm.ptrauth.resign(i64 %addr) [ "ptrauth"(i64 2, i64 42, i64 0), "ptrauth"(i64 2, i64 123, i64 0) ]
  ret i64 %signed
}
