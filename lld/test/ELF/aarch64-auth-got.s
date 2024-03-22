# RUN: split-file %s %t0
# REQUIRES: aarch64

# RUN: llvm-mc -filetype=obj -triple=aarch64-none-linux %p/Inputs/shared.s -o %t-lib.o
# RUN: ld.lld -shared %t-lib.o -soname t-lib.so -o %t-lib.so

#--- ok.s

# RUN: llvm-mc -filetype=obj -triple=aarch64-none-linux %t0/ok.s -o %tok.o

# RUN: ld.lld %t-lib.so %tok.o -o %tok.exe
# RUN:  llvm-readelf -r -S -x .got %tok.exe | FileCheck %s --check-prefix=OK

# OK:    Offset             Info             Type               Symbol's Value    Symbol's Name + Addend
# OK-NEXT:    0000000000220360  000000010000e201 R_AARCH64_AUTH_GLOB_DAT 0000000000000000 bar + 0
# OK-NEXT:    0000000000220368  000000020000e201 R_AARCH64_AUTH_GLOB_DAT 0000000000000000 zed + 0

# OK:      Hex dump of section '.got':
# OK-NEXT: 0x00220360 00000000 00000080 00000000 000000a0

.globl _start
_start:
  adrp x0, :got_auth:bar
  ldr  x0, [x0, :got_auth_lo12:bar]
  adrp x0, :got_auth:zed
  ldr  x0, [x0, :got_auth_lo12:zed]

#--- err.s

# RUN: llvm-mc -filetype=obj -triple=aarch64-none-linux %t0/err.s -o %terr.o

# RUN: not ld.lld %t-lib.so %terr.o -o %terr.exe 2>&1 | FileCheck %s --check-prefix=ERR

# ERR:  error: Both auth and non-auth got entries for a symbol bar requested. Only one type of got entry per symbol is supported.

.globl _start
_start:
  adrp x0, :got_auth:bar
  ldr  x0, [x0, :got_auth_lo12:bar]
  adrp x0, :got:bar
  ldr  x0, [x0, :got_lo12:bar]