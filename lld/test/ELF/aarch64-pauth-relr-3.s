# REQUIRES: aarch64

# RUN: llvm-mc -filetype=obj -triple=aarch64 %s -o %t.o
# RUN: ld.lld -shared -z pack-relative-relocs %t.o -o %t
# RUN: llvm-readelf -S -d -s %t | FileCheck %s
# RUN: llvm-readelf -S -d -s %t 2>&1 >/dev/null | FileCheck %s --allow-empty --check-prefix=WARN

# CHECK: .rela.dyn         RELA            0000000000000248 000248 000018 18   A  0   0  8
# CHECK: .relr.auth.dyn    AARCH64_AUTH_RELR 0000000000000260 000260 000008 08   A  0   0  8
# CHECK: .dynamic          DYNAMIC         0000000000020268 000268 0000d0 10  WA  4   0  8
# CHECK: Dynamic section at offset 0x268 contains 13 entries:
# CHECK:   Tag                Type                   Name/Value
# CHECK:   0x0000000000000007 (RELA)                 0x248
# CHECK:   0x0000000000000008 (RELASZ)               24 (bytes)
# CHECK:   0x0000000000000009 (RELAENT)              24 (bytes)
# CHECK:   0x0000000070000012 (AARCH64_AUTH_RELR)    0x260
# CHECK:   0x0000000070000011 (AARCH64_AUTH_RELRSZ)  8 (bytes)
# CHECK:   0x0000000070000013 (AARCH64_AUTH_RELRENT) 8 (bytes)
# CHECK:   0x0000000000000006 (SYMTAB)               0x200
# CHECK:   0x000000000000000b (SYMENT)               24 (bytes)
# CHECK:   0x0000000000000005 (STRTAB)               0x244
# CHECK:   0x000000000000000a (STRSZ)                1 (bytes)
# CHECK:   0x000000006ffffef5 (GNU_HASH)             0x218
# CHECK:   0x0000000000000004 (HASH)                 0x234
# CHECK:   0x0000000000000000 (NULL)                 0x0
# CHECK: 0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT   UND

# WARN-NOT: warning:

.data
.balign 8
foo:
## Can stay in .relr.auth.dyn
.quad foo@AUTH(da,42)
## Will be moved to .rela.dyn
.quad foo+0x100000000@AUTH(da,42)
