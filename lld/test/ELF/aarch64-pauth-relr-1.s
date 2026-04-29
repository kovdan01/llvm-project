# REQUIRES: aarch64

# RUN: llvm-mc -filetype=obj -triple=aarch64 %s -o %t.o
# RUN: ld.lld -static -z pack-relative-relocs %t.o -o %t
# RUN: llvm-readelf -S -s %t | FileCheck %s

# CHECK: .rela.dyn         RELA            00000000002001c8 0001c8 000030 18   A  0   0  8
# CHECK: 00000000002001c8     0 NOTYPE  LOCAL  HIDDEN      1 __rela_iplt_start
## XXX: Only covers 0x18 bytes for one relocation, not 0x30 bytes for both
# CHECK: 00000000002001f8     0 NOTYPE  LOCAL  HIDDEN      1 __rela_iplt_end

adrp x0, __rela_iplt_start
adrp x0, __rela_iplt_end

.data
.balign 8
foo:
## Will be moved to .rela.dyn
.quad foo+0x100000000@AUTH(da,42)

## Extra relocation in a section with alignment 1 to force it into .rela.dyn
## up-front.
.section .data.rel.ro, "aw"
.quad foo@AUTH(da,42)
