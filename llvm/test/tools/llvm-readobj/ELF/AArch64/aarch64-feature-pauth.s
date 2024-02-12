# TODO: it looks like that tests might be shortened using some kind of templates

# RUN: rm -rf %t && split-file %s %t && cd %t

#--- tag-42-1.s

.section ".note.AARCH64-PAUTH-ABI-tag", "a"
.long 4
.long 16
.long 1
.asciz "ARM"

.quad 42         // platform
.quad 1          // version

# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu tag-42-1.s -o tag-42-1.o
# RUN: llvm-readelf --notes tag-42-1.o | FileCheck --check-prefix ELF-TAG-42-1 %s
# RUN: llvm-readobj --notes tag-42-1.o | FileCheck --check-prefix OBJ-TAG-42-1 %s

# ELF-TAG-42-1: AArch64 PAuth ABI tag: platform 0x2a, version 0x1

# OBJ-TAG-42-1:      Notes [
# OBJ-TAG-42-1-NEXT:   NoteSection {
# OBJ-TAG-42-1-NEXT:     Name: .note.AARCH64-PAUTH-ABI-tag
# OBJ-TAG-42-1-NEXT:     Offset: 0x40
# OBJ-TAG-42-1-NEXT:     Size: 0x20
# OBJ-TAG-42-1-NEXT:     Note {
# OBJ-TAG-42-1-NEXT:       Owner: ARM
# OBJ-TAG-42-1-NEXT:       Data size: 0x10
# OBJ-TAG-42-1-NEXT:       Type: NT_ARM_TYPE_PAUTH_ABI_TAG
# OBJ-TAG-42-1-NEXT:       Platform: 42
# OBJ-TAG-42-1-NEXT:       Version: 1
# OBJ-TAG-42-1-NEXT:     }
# OBJ-TAG-42-1-NEXT:   }
# OBJ-TAG-42-1-NEXT: ]

#--- tag-0-0.s

.section ".note.AARCH64-PAUTH-ABI-tag", "a"
.long 4
.long 16
.long 1
.asciz "ARM"

.quad 0          // platform
.quad 0          // version

# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu tag-0-0.s -o tag-0-0.o
# RUN: llvm-readelf --notes tag-0-0.o | FileCheck --check-prefix ELF-TAG-0-0 %s
# RUN: llvm-readobj --notes tag-0-0.o | FileCheck --check-prefix OBJ-TAG-0-0 %s

# ELF-TAG-0-0: AArch64 PAuth ABI tag: platform 0x0 (invalid), version 0x0

# OBJ-TAG-0-0:      Notes [
# OBJ-TAG-0-0-NEXT:   NoteSection {
# OBJ-TAG-0-0-NEXT:     Name: .note.AARCH64-PAUTH-ABI-tag
# OBJ-TAG-0-0-NEXT:     Offset: 0x40
# OBJ-TAG-0-0-NEXT:     Size: 0x20
# OBJ-TAG-0-0-NEXT:     Note {
# OBJ-TAG-0-0-NEXT:       Owner: ARM
# OBJ-TAG-0-0-NEXT:       Data size: 0x10
# OBJ-TAG-0-0-NEXT:       Type: NT_ARM_TYPE_PAUTH_ABI_TAG
# OBJ-TAG-0-0-NEXT:       Platform: 0
# OBJ-TAG-0-0-NEXT:       Version: 0
# OBJ-TAG-0-0-NEXT:     }
# OBJ-TAG-0-0-NEXT:   }
# OBJ-TAG-0-0-NEXT: ]

#--- tag-1-0.s

.section ".note.AARCH64-PAUTH-ABI-tag", "a"
.long 4
.long 16
.long 1
.asciz "ARM"

.quad 1          // platform
.quad 0          // version

# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu tag-1-0.s -o tag-1-0.o
# RUN: llvm-readelf --notes tag-1-0.o | FileCheck --check-prefix ELF-TAG-1-0 %s
# RUN: llvm-readobj --notes tag-1-0.o | FileCheck --check-prefix OBJ-TAG-1-0 %s

# ELF-TAG-1-0: AArch64 PAuth ABI tag: platform 0x1 (baremetal), version 0x0

# OBJ-TAG-1-0:      Notes [
# OBJ-TAG-1-0-NEXT:   NoteSection {
# OBJ-TAG-1-0-NEXT:     Name: .note.AARCH64-PAUTH-ABI-tag
# OBJ-TAG-1-0-NEXT:     Offset: 0x40
# OBJ-TAG-1-0-NEXT:     Size: 0x20
# OBJ-TAG-1-0-NEXT:     Note {
# OBJ-TAG-1-0-NEXT:       Owner: ARM
# OBJ-TAG-1-0-NEXT:       Data size: 0x10
# OBJ-TAG-1-0-NEXT:       Type: NT_ARM_TYPE_PAUTH_ABI_TAG
# OBJ-TAG-1-0-NEXT:       Platform: 1
# OBJ-TAG-1-0-NEXT:       Version: 0
# OBJ-TAG-1-0-NEXT:     }
# OBJ-TAG-1-0-NEXT:   }
# OBJ-TAG-1-0-NEXT: ]

#--- tag-2-21.s

.section ".note.AARCH64-PAUTH-ABI-tag", "a"
.long 4
.long 16
.long 1
.asciz "ARM"

.quad 2          // platform
.quad 21         // version

# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu tag-2-21.s -o tag-2-21.o
# RUN: llvm-readelf --notes tag-2-21.o | FileCheck --check-prefix ELF-TAG-2-21 %s
# RUN: llvm-readobj --notes tag-2-21.o | FileCheck --check-prefix OBJ-TAG-2-21 %s

# ELF-TAG-2-21: AArch64 PAuth ABI tag: platform 0x2 (linux), version 0x15 (PointerAuthCalls, !PointerAuthReturns, PointerAuthVTPtrAddressDiscrimination, !PointerAuthVTPtrTypeDiscrimination, PointerAuthInitFini)

# OBJ-TAG-2-21:      Notes [
# OBJ-TAG-2-21-NEXT:   NoteSection {
# OBJ-TAG-2-21-NEXT:     Name: .note.AARCH64-PAUTH-ABI-tag
# OBJ-TAG-2-21-NEXT:     Offset: 0x40
# OBJ-TAG-2-21-NEXT:     Size: 0x20
# OBJ-TAG-2-21-NEXT:     Note {
# OBJ-TAG-2-21-NEXT:       Owner: ARM
# OBJ-TAG-2-21-NEXT:       Data size: 0x10
# OBJ-TAG-2-21-NEXT:       Type: NT_ARM_TYPE_PAUTH_ABI_TAG
# OBJ-TAG-2-21-NEXT:       Platform: 2
# OBJ-TAG-2-21-NEXT:       Version: 21
# OBJ-TAG-2-21-NEXT:     }
# OBJ-TAG-2-21-NEXT:   }
# OBJ-TAG-2-21-NEXT: ]

#--- tag-short.s

.section ".note.AARCH64-PAUTH-ABI-tag", "a"
.long 4
.long 12
.long 1
.asciz "ARM"

.quad 42
.word 1

# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu tag-short.s -o tag-short.o
# RUN: llvm-readelf --notes tag-short.o | FileCheck --check-prefix ELF-TAG-SHORT  %s
# TODO
# RUN: llvm-readobj --notes tag-short.o | FileCheck --check-prefix OBJ-TAG-SHORT %s

# ELF-TAG-SHORT:  AArch64 PAuth ABI tag: <corrupted size: expected 16, got 12>

# OBJ-TAG-SHORT:      Notes [
# OBJ-TAG-SHORT-NEXT:   NoteSection {
# OBJ-TAG-SHORT-NEXT:     Name: .note.AARCH64-PAUTH-ABI-tag
# OBJ-TAG-SHORT-NEXT:     Offset: 0x40
# OBJ-TAG-SHORT-NEXT:     Size: 0x1C
# OBJ-TAG-SHORT-NEXT:     Note {
# OBJ-TAG-SHORT-NEXT:       Owner: ARM
# OBJ-TAG-SHORT-NEXT:       Data size: 0xC
# OBJ-TAG-SHORT-NEXT:       Type: NT_ARM_TYPE_PAUTH_ABI_TAG
# OBJ-TAG-SHORT-NEXT:       Description data (
# OBJ-TAG-SHORT-NEXT:         0000: 2A000000 00000000 01000000
# OBJ-TAG-SHORT-NEXT:       )
# OBJ-TAG-SHORT-NEXT:     }
# OBJ-TAG-SHORT-NEXT:   }
# OBJ-TAG-SHORT-NEXT: ]

#--- tag-long.s

.section ".note.AARCH64-PAUTH-ABI-tag", "a"
.long 4
.long 24
.long 1
.asciz "ARM"

.quad 42         // platform
.quad 1          // version
.quad 0x0123456789ABCDEF // extra data

# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu tag-long.s -o tag-long.o
# RUN: llvm-readelf --notes tag-long.o | FileCheck --check-prefix ELF-TAG-LONG   %s
# TODO
# RUN: llvm-readobj --notes tag-long.o | FileCheck --check-prefix OBJ-TAG-LONG %s

# ELF-TAG-LONG:   AArch64 PAuth ABI tag: <corrupted size: expected 16, got 24>

# OBJ-TAG-LONG:      Notes [
# OBJ-TAG-LONG-NEXT:   NoteSection {
# OBJ-TAG-LONG-NEXT:     Name: .note.AARCH64-PAUTH-ABI-tag
# OBJ-TAG-LONG-NEXT:     Offset: 0x40
# OBJ-TAG-LONG-NEXT:     Size: 0x28
# OBJ-TAG-LONG-NEXT:     Note {
# OBJ-TAG-LONG-NEXT:       Owner: ARM
# OBJ-TAG-LONG-NEXT:       Data size: 0x18
# OBJ-TAG-LONG-NEXT:       Type: NT_ARM_TYPE_PAUTH_ABI_TAG
# OBJ-TAG-LONG-NEXT:       Description data (
# OBJ-TAG-LONG-NEXT:         0000: 2A000000 00000000 01000000 00000000
# OBJ-TAG-LONG-NEXT:         0010: EFCDAB89 67452301
# OBJ-TAG-LONG-NEXT:       )
# OBJ-TAG-LONG-NEXT:     }
# OBJ-TAG-LONG-NEXT:   }
# OBJ-TAG-LONG-NEXT: ]

#--- gnu-42-1.s

.section ".note.gnu.property", "a"
  .long 4           /* Name length is always 4 ("GNU") */
  .long end - begin /* Data length */
  .long 5           /* Type: NT_GNU_PROPERTY_TYPE_0 */
  .asciz "GNU"      /* Name */
  .p2align 3
begin:
  /* PAuth ABI property note */
  .long 0xc0000001  /* Type: GNU_PROPERTY_AARCH64_FEATURE_PAUTH */
  .long 16          /* Data size */
  .quad 42          /* PAuth ABI platform */
  .quad 1           /* PAuth ABI version */
  .p2align 3        /* Align to 8 byte for 64 bit */
end:

# RUN: llvm-mc -filetype=obj -triple aarch64-linux-gnu gnu-42-1.s -o gnu-42-1.o
# RUN: llvm-readelf --notes gnu-42-1.o | FileCheck %s --check-prefix=ELF-GNU-42-1
# RUN: llvm-readobj --notes gnu-42-1.o | FileCheck %s --check-prefix=OBJ-GNU-42-1

# ELF-GNU-42-1: Displaying notes found in: .note.gnu.property
# ELF-GNU-42-1-NEXT:   Owner                 Data size	Description
# ELF-GNU-42-1-NEXT:   GNU                   0x00000018	NT_GNU_PROPERTY_TYPE_0 (property note)
# ELF-GNU-42-1-NEXT:   AArch64 PAuth ABI tag: platform 0x2a, version 0x1

# OBJ-GNU-42-1:      Notes [
# OBJ-GNU-42-1-NEXT:   NoteSection {
# OBJ-GNU-42-1-NEXT:     Name: .note.gnu.property
# OBJ-GNU-42-1-NEXT:     Offset: 0x40
# OBJ-GNU-42-1-NEXT:     Size: 0x28
# OBJ-GNU-42-1-NEXT:     Note {
# OBJ-GNU-42-1-NEXT:       Owner: GNU
# OBJ-GNU-42-1-NEXT:       Data size: 0x18
# OBJ-GNU-42-1-NEXT:       Type: NT_GNU_PROPERTY_TYPE_0 (property note)
# OBJ-GNU-42-1-NEXT:       Property [
# OBJ-GNU-42-1-NEXT:         AArch64 PAuth ABI tag: platform 0x2a, version 0x1
# OBJ-GNU-42-1-NEXT:       ]
# OBJ-GNU-42-1-NEXT:     }
# OBJ-GNU-42-1-NEXT:   }
# OBJ-GNU-42-1-NEXT: ]

#--- gnu-0-0.s

.section ".note.gnu.property", "a"
  .long 4           /* Name length is always 4 ("GNU") */
  .long end - begin /* Data length */
  .long 5           /* Type: NT_GNU_PROPERTY_TYPE_0 */
  .asciz "GNU"      /* Name */
  .p2align 3
begin:
  /* PAuth ABI property note */
  .long 0xc0000001  /* Type: GNU_PROPERTY_AARCH64_FEATURE_PAUTH */
  .long 16          /* Data size */
  .quad 0           /* PAuth ABI platform */
  .quad 0           /* PAuth ABI version */
  .p2align 3        /* Align to 8 byte for 64 bit */
end:

# RUN: llvm-mc -filetype=obj -triple aarch64-linux-gnu gnu-0-0.s -o gnu-0-0.o
# RUN: llvm-readelf --notes gnu-0-0.o | FileCheck %s --check-prefix=ELF-GNU-0-0
# RUN: llvm-readobj --notes gnu-0-0.o | FileCheck %s --check-prefix=OBJ-GNU-0-0

# ELF-GNU-0-0: Displaying notes found in: .note.gnu.property
# ELF-GNU-0-0-NEXT:   Owner                 Data size	Description
# ELF-GNU-0-0-NEXT:   GNU                   0x00000018	NT_GNU_PROPERTY_TYPE_0 (property note)
# ELF-GNU-0-0-NEXT:   AArch64 PAuth ABI tag: platform 0x0 (invalid), version 0x0

# OBJ-GNU-0-0:      Notes [
# OBJ-GNU-0-0-NEXT:   NoteSection {
# OBJ-GNU-0-0-NEXT:     Name: .note.gnu.property
# OBJ-GNU-0-0-NEXT:     Offset: 0x40
# OBJ-GNU-0-0-NEXT:     Size: 0x28
# OBJ-GNU-0-0-NEXT:     Note {
# OBJ-GNU-0-0-NEXT:       Owner: GNU
# OBJ-GNU-0-0-NEXT:       Data size: 0x18
# OBJ-GNU-0-0-NEXT:       Type: NT_GNU_PROPERTY_TYPE_0 (property note)
# OBJ-GNU-0-0-NEXT:       Property [
# OBJ-GNU-0-0-NEXT:         AArch64 PAuth ABI tag: platform 0x0 (invalid), version 0x0
# OBJ-GNU-0-0-NEXT:       ]
# OBJ-GNU-0-0-NEXT:     }
# OBJ-GNU-0-0-NEXT:   }
# OBJ-GNU-0-0-NEXT: ]

#--- gnu-1-0.s

.section ".note.gnu.property", "a"
  .long 4           /* Name length is always 4 ("GNU") */
  .long end - begin /* Data length */
  .long 5           /* Type: NT_GNU_PROPERTY_TYPE_0 */
  .asciz "GNU"      /* Name */
  .p2align 3
begin:
  /* PAuth ABI property note */
  .long 0xc0000001  /* Type: GNU_PROPERTY_AARCH64_FEATURE_PAUTH */
  .long 16          /* Data size */
  .quad 1           /* PAuth ABI platform */
  .quad 0           /* PAuth ABI version */
  .p2align 3        /* Align to 8 byte for 64 bit */
end:

# RUN: llvm-mc -filetype=obj -triple aarch64-linux-gnu gnu-0-0.s -o gnu-0-0.o
# RUN: llvm-readelf --notes gnu-0-0.o | FileCheck %s --check-prefix=ELF-GNU-0-0
# RUN: llvm-readobj --notes gnu-0-0.o | FileCheck %s --check-prefix=OBJ-GNU-0-0

# ELF-GNU-1-0: Displaying notes found in: .note.gnu.property
# ELF-GNU-1-0-NEXT:   Owner                 Data size	Description
# ELF-GNU-1-0-NEXT:   GNU                   0x00000018	NT_GNU_PROPERTY_TYPE_0 (property note)
# ELF-GNU-1-0-NEXT:   AArch64 PAuth ABI tag: platform 0x1 (baremetal), version 0x0

# OBJ-GNU-1-0:      Notes [
# OBJ-GNU-1-0-NEXT:   NoteSection {
# OBJ-GNU-1-0-NEXT:     Name: .note.gnu.property
# OBJ-GNU-1-0-NEXT:     Offset: 0x40
# OBJ-GNU-1-0-NEXT:     Size: 0x28
# OBJ-GNU-1-0-NEXT:     Note {
# OBJ-GNU-1-0-NEXT:       Owner: GNU
# OBJ-GNU-1-0-NEXT:       Data size: 0x18
# OBJ-GNU-1-0-NEXT:       Type: NT_GNU_PROPERTY_TYPE_0 (property note)
# OBJ-GNU-1-0-NEXT:       Property [
# OBJ-GNU-1-0-NEXT:         AArch64 PAuth ABI tag: platform 0x1 (baremetal), version 0x0
# OBJ-GNU-1-0-NEXT:       ]
# OBJ-GNU-1-0-NEXT:     }
# OBJ-GNU-1-0-NEXT:   }
# OBJ-GNU-1-0-NEXT: ]

#--- gnu-2-21.s

.section ".note.gnu.property", "a"
  .long 4           /* Name length is always 4 ("GNU") */
  .long end - begin /* Data length */
  .long 5           /* Type: NT_GNU_PROPERTY_TYPE_0 */
  .asciz "GNU"      /* Name */
  .p2align 3
begin:
  /* PAuth ABI property note */
  .long 0xc0000001  /* Type: GNU_PROPERTY_AARCH64_FEATURE_PAUTH */
  .long 16          /* Data size */
  .quad 2           /* PAuth ABI platform */
  .quad 21          /* PAuth ABI version */
  .p2align 3        /* Align to 8 byte for 64 bit */
end:

# RUN: llvm-mc -filetype=obj -triple aarch64-linux-gnu gnu-2-21.s -o gnu-2-21.o
# RUN: llvm-readelf --notes gnu-2-21.o | FileCheck %s --check-prefix=ELF-GNU-2-21
# RUN: llvm-readobj --notes gnu-2-21.o | FileCheck %s --check-prefix=OBJ-GNU-2-21

# ELF-GNU-2-21: Displaying notes found in: .note.gnu.property
# ELF-GNU-2-21-NEXT:   Owner                 Data size	Description
# ELF-GNU-2-21-NEXT:   GNU                   0x00000018	NT_GNU_PROPERTY_TYPE_0 (property note)
# ELF-GNU-2-21-NEXT:   AArch64 PAuth ABI tag: platform 0x2 (linux), version 0x15 (PointerAuthCalls, !PointerAuthReturns, PointerAuthVTPtrAddressDiscrimination, !PointerAuthVTPtrTypeDiscrimination, PointerAuthInitFini)

# OBJ-GNU-2-21:      Notes [
# OBJ-GNU-2-21-NEXT:   NoteSection {
# OBJ-GNU-2-21-NEXT:     Name: .note.gnu.property
# OBJ-GNU-2-21-NEXT:     Offset: 0x40
# OBJ-GNU-2-21-NEXT:     Size: 0x28
# OBJ-GNU-2-21-NEXT:     Note {
# OBJ-GNU-2-21-NEXT:       Owner: GNU
# OBJ-GNU-2-21-NEXT:       Data size: 0x18
# OBJ-GNU-2-21-NEXT:       Type: NT_GNU_PROPERTY_TYPE_0 (property note)
# OBJ-GNU-2-21-NEXT:       Property [
# OBJ-GNU-2-21-NEXT:         AArch64 PAuth ABI tag: platform 0x2 (linux), version 0x15 (PointerAuthCalls, !PointerAuthReturns, PointerAuthVTPtrAddressDiscrimination, !PointerAuthVTPtrTypeDiscrimination, PointerAuthInitFini)
# OBJ-GNU-2-21-NEXT:       ]
# OBJ-GNU-2-21-NEXT:     }
# OBJ-GNU-2-21-NEXT:   }
# OBJ-GNU-2-21-NEXT: ]

#--- gnu-short.s

.section ".note.gnu.property", "a"
  .long 4           /* Name length is always 4 ("GNU") */
  .long end - begin /* Data length */
  .long 5           /* Type: NT_GNU_PROPERTY_TYPE_0 */
  .asciz "GNU"      /* Name */
  .p2align 3
begin:
  /* PAuth ABI property note */
  .long 0xc0000001  /* Type: GNU_PROPERTY_AARCH64_FEATURE_PAUTH */
  .long 12          /* Data size */
  .quad 42          /* PAuth ABI platform */
  .word 1           /* PAuth ABI version */
  .p2align 3        /* Align to 8 byte for 64 bit */
end:

# RUN: llvm-mc -filetype=obj -triple aarch64-linux-gnu gnu-short.s -o gnu-short.o
# RUN: llvm-readelf --notes gnu-short.o | FileCheck %s --check-prefix=ELF-GNU-SHORT
# RUN: llvm-readobj --notes gnu-short.o | FileCheck %s --check-prefix=OBJ-GNU-SHORT

# ELF-GNU-SHORT: Displaying notes found in: .note.gnu.property
# ELF-GNU-SHORT-NEXT:   Owner                 Data size	Description
# ELF-GNU-SHORT-NEXT:   GNU                   0x00000018	NT_GNU_PROPERTY_TYPE_0 (property note)
# ELF-GNU-SHORT-NEXT:   AArch64 PAuth ABI tag: <corrupted size: expected 16, got 12>

# OBJ-GNU-SHORT:      Notes [
# OBJ-GNU-SHORT-NEXT:   NoteSection {
# OBJ-GNU-SHORT-NEXT:     Name: .note.gnu.property
# OBJ-GNU-SHORT-NEXT:     Offset: 0x40
# OBJ-GNU-SHORT-NEXT:     Size: 0x28
# OBJ-GNU-SHORT-NEXT:     Note {
# OBJ-GNU-SHORT-NEXT:       Owner: GNU
# OBJ-GNU-SHORT-NEXT:       Data size: 0x18
# OBJ-GNU-SHORT-NEXT:       Type: NT_GNU_PROPERTY_TYPE_0 (property note)
# OBJ-GNU-SHORT-NEXT:       Property [
# OBJ-GNU-SHORT-NEXT:         AArch64 PAuth ABI tag: <corrupted size: expected 16, got 12>
# OBJ-GNU-SHORT-NEXT:       ]
# OBJ-GNU-SHORT-NEXT:     }
# OBJ-GNU-SHORT-NEXT:   }
# OBJ-GNU-SHORT-NEXT: ]


#--- gnu-long.s

.section ".note.gnu.property", "a"
  .long 4           /* Name length is always 4 ("GNU") */
  .long end - begin /* Data length */
  .long 5           /* Type: NT_GNU_PROPERTY_TYPE_0 */
  .asciz "GNU"      /* Name */
  .p2align 3
begin:
  /* PAuth ABI property note */
  .long 0xc0000001  /* Type: GNU_PROPERTY_AARCH64_FEATURE_PAUTH */
  .long 24          /* Data size */
  .quad 42          /* PAuth ABI platform */
  .quad 1           /* PAuth ABI version */
  .quad 0x0123456789ABCDEF
  .p2align 3        /* Align to 8 byte for 64 bit */
end:

# RUN: llvm-mc -filetype=obj -triple aarch64-linux-gnu gnu-long.s -o gnu-long.o
# RUN: llvm-readelf --notes gnu-long.o | FileCheck %s --check-prefix=ELF-GNU-LONG
# RUN: llvm-readobj --notes gnu-long.o | FileCheck %s --check-prefix=OBJ-GNU-LONG

# ELF-GNU-LONG: Displaying notes found in: .note.gnu.property
# ELF-GNU-LONG-NEXT:   Owner                 Data size	Description
# ELF-GNU-LONG-NEXT:   GNU                   0x00000020	NT_GNU_PROPERTY_TYPE_0 (property note)
# ELF-GNU-LONG-NEXT:   AArch64 PAuth ABI tag: <corrupted size: expected 16, got 24>

# OBJ-GNU-LONG:      Notes [
# OBJ-GNU-LONG-NEXT:   NoteSection {
# OBJ-GNU-LONG-NEXT:     Name: .note.gnu.property
# OBJ-GNU-LONG-NEXT:     Offset: 0x40
# OBJ-GNU-LONG-NEXT:     Size: 0x30
# OBJ-GNU-LONG-NEXT:     Note {
# OBJ-GNU-LONG-NEXT:       Owner: GNU
# OBJ-GNU-LONG-NEXT:       Data size: 0x20
# OBJ-GNU-LONG-NEXT:       Type: NT_GNU_PROPERTY_TYPE_0 (property note)
# OBJ-GNU-LONG-NEXT:       Property [
# OBJ-GNU-LONG-NEXT:         AArch64 PAuth ABI tag: <corrupted size: expected 16, got 24>
# OBJ-GNU-LONG-NEXT:       ]
# OBJ-GNU-LONG-NEXT:     }
# OBJ-GNU-LONG-NEXT:   }
# OBJ-GNU-LONG-NEXT: ]
