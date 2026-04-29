# REQUIRES: aarch64

# RUN: llvm-mc -filetype=obj -triple=aarch64 %s -o %t.o
# RUN: ld.lld -pie -z pack-relative-relocs %t.o -o %t
# RUN: llvm-readelf -S -d -s -x.dynamic %t | FileCheck %s

# CHECK: .rela.dyn         RELA            0000000000000248 000248 000030 18   A  1   0  8
# CHECK: .relr.auth.dyn    AARCH64_AUTH_RELR 0000000000000278 000278 000000 08   A  0   0  8
# CHECK: .text             PROGBITS        0000000000010278 000278 000000 00  AX  0   0  4
# CHECK: .data.rel.ro      PROGBITS        0000000000020278 000278 000008 00  WA  0   0  1
## XXX: Claims 15 entries but only 12 present (extra NULLs)
# CHECK: .dynamic          DYNAMIC         0000000000020280 000280 0000f0 10  WA  4   0  8
# CHECK: Dynamic section at offset 0x280 contains 12 entries:
# CHECK:   Tag                Type       Name/Value
# CHECK:   0x000000006ffffffb (FLAGS_1)  PIE
# CHECK:   0x0000000000000015 (DEBUG)    0x0
# CHECK:   0x0000000000000007 (RELA)     0x248
# CHECK:   0x0000000000000008 (RELASZ)   48 (bytes)
# CHECK:   0x0000000000000009 (RELAENT)  24 (bytes)
# CHECK:   0x0000000000000006 (SYMTAB)   0x200
# CHECK:   0x000000000000000b (SYMENT)   24 (bytes)
# CHECK:   0x0000000000000005 (STRTAB)   0x244
# CHECK:   0x000000000000000a (STRSZ)    1 (bytes)
# CHECK:   0x000000006ffffef5 (GNU_HASH) 0x218
# CHECK:   0x0000000000000004 (HASH)     0x234
# CHECK:   0x0000000000000000 (NULL)     0x0
## All 4 NULLs, not just 1 (see above)
# CHECK: 0x00020330 00000000 00000000 00000000 00000000 ................
# CHECK: 0x00020340 00000000 00000000 00000000 00000000 ................
# CHECK: 0x00020350 00000000 00000000 00000000 00000000 ................
# CHECK: 0x00020360 00000000 00000000 00000000 00000000 ................

.data
.balign 8
foo:
## Will be moved to .rela.dyn
.quad foo+0x100000000@AUTH(da,42)

## Extra relocation in a section with alignment 1 to force it into .rela.dyn
## up-front.
.section .data.rel.ro, "aw"
.quad foo@AUTH(da,42)
