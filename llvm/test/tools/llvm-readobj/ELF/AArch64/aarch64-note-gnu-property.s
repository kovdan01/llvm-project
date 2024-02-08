// TODO: support for GNU_PROPERTY_AARCH64_FEATURE_PAUTH

// RUN: llvm-mc -filetype=obj -triple aarch64-linux-gnu %s -o %t
// RUN: llvm-readelf --notes %t | FileCheck %s --check-prefix=GNU
// RUN: llvm-readobj --notes %t | FileCheck %s --check-prefix=LLVM

// GNU: Displaying notes found in: .note.gnu.property
// GNU-NEXT:   Owner                 Data size	Description
// GNU-NEXT:   GNU                   0x00000028	NT_GNU_PROPERTY_TYPE_0 (property note)
// GNU-NEXT:     Properties:    aarch64 feature: BTI, PAC
// GNU-NEXT:                    <application-specific type 0xc0000001>

// LLVM:      Notes [
// LLVM-NEXT:   NoteSection {
// LLVM-NEXT:     Name: .note.gnu.property
// LLVM-NEXT:     Offset: 0x40
// LLVM-NEXT:     Size: 0x38
// LLVM-NEXT:     Note {
// LLVM-NEXT:       Owner: GNU
// LLVM-NEXT:       Data size: 0x28
// LLVM-NEXT:       Type: NT_GNU_PROPERTY_TYPE_0 (property note)
// LLVM-NEXT:       Property [
// LLVM-NEXT:         aarch64 feature: BTI, PAC
// LLVM-NEXT:         <application-specific type 0xc0000001>
// LLVM-NEXT:       ]
// LLVM-NEXT:     }
// LLVM-NEXT:   }
// LLVM-NEXT: ]

.section ".note.gnu.property", "a"
  .long 4           /* Name length is always 4 ("GNU") */
  .long end - begin /* Data length */
  .long 5           /* Type: NT_GNU_PROPERTY_TYPE_0 */
  .asciz "GNU"      /* Name */
  .p2align 3
begin:
  /* BTI and PAC property note */
  .long 0xc0000000  /* Type: GNU_PROPERTY_AARCH64_FEATURE_1_AND */
  .long 4           /* Data size */
  .long 3           /* BTI and PAC */
  .p2align 3        /* Align to 8 byte for 64 bit */
  /* PAuth ABI property note */
  .long 0xc0000001  /* Type: GNU_PROPERTY_AARCH64_FEATURE_PAUTH */
  .long 16          /* Data size */
  .quad 2           /* PAuth ABI platform */
  .quad 31          /* PAuth ABI version */
  .p2align 3        /* Align to 8 byte for 64 bit */
end:
