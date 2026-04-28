# REQUIRES: aarch64
# RUN: llvm-mc -filetype=obj -triple=aarch64 %s -o %t.o
# RUN: ld.lld -shared %t.o -o %t
# RUN: llvm-readobj -r %t | FileCheck %s --check-prefix=RELA
# RUN: llvm-readelf -x.got %t | FileCheck %s --check-prefix=GOT
# RUN: llvm-objdump -d --no-show-raw-insn %t | FileCheck %s --check-prefix=DIS

## Verify that an auth GOT entry for a weak undefined symbol is resolved to
## NULL (plus addend).

# RELA-LABEL: Relocations [
# RELA-NEXT:  ]

# GOT-LABEL: Hex dump of section '.got':
# GOT-NEXT:  0x000202b0 00000000 00000000

# DIS-LABEL: <_start>:
# DIS-NEXT:    adrp x0, 0x20000
# DIS-NEXT:    ldr  x0, [x0, #0x2b0]

.weak undef
.hidden undef

.globl _start
_start:
  adrp x0, :got_auth:undef
  ldr x0, [x0, :got_auth_lo12:undef]
