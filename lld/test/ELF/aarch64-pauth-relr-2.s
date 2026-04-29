# REQUIRES: aarch64

# RUN: llvm-mc -filetype=obj -triple=aarch64 %s -o %t.o
# RUN: ld.lld -static -z pack-relative-relocs %t.o -o %t
# RUN: llvm-readelf -S -s %t | FileCheck %s

# CHECK: .rela.dyn         RELA            0000000000200158 000158 000018 18   A  0   0  8
## XXX: ELF header's address
# CHECK: 0000000000200158     0 NOTYPE  LOCAL  HIDDEN      1 __rela_iplt_start
# CHECK: 0000000000200170     0 NOTYPE  LOCAL  HIDDEN      1 __rela_iplt_end

adrp x0, __rela_iplt_start
adrp x0, __rela_iplt_end

.data
.balign 8
foo:
## Will be moved to .rela.dyn
.quad foo+0x100000000@AUTH(da,42)
