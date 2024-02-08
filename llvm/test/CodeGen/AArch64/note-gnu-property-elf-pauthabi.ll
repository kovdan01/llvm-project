; RUN: llc -mtriple=aarch64-linux %s               -o - | \
; RUN:   FileCheck %s --check-prefix=ASM
; RUN: llc -mtriple=aarch64-linux %s -filetype=obj -o - |  \
; RUN:   llvm-readelf --notes - | FileCheck %s --check-prefix=OBJ
@x = common dso_local global i32 0, align 4

; attributes #0 = { "branch-target-enforcement"="true" }

!llvm.module.flags = !{!0, !1}

!0 = !{i32 1, !"aarch64-elf-pauthabi-platform", i32 2}
!1 = !{i32 1, !"aarch64-elf-pauthabi-version", i32 31}

; ASM: .section .note.gnu.property,"a",@note
; ASM-NEXT: .p2align 3, 0x0
; ASM-NEXT: .word 4
; ASM-NEXT: .word 24
; ASM-NEXT: .word 5
; ASM-NEXT: .asciz "GNU"
; 3221225473 = 0xc0000001 = GNU_PROPERTY_AARCH64_FEATURE_PAUTH
; ASM-NEXT: .word 3221225473
; ASM-NEXT: .word 16
; ASM-NEXT: .xword 2
; ASM-NEXT: .xword 31

; SM:	    .word	3221225472
; SM-NEXT:	.word	4
; SM-NEXT:	.word	3

; TODO: llvm-readelf support
; OBJ: <application-specific type 0xc0000001>
