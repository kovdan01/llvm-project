# REQUIRES: aarch64
# RUN: llvm-mc -filetype=obj -triple=aarch64 %s -o %t.o
# RUN: ld.lld -shared %t.o -o %t
# RUN: llvm-readobj -r %t | FileCheck %s --check-prefix=RELA
# RUN: llvm-readelf -x.data %t | FileCheck %s --check-prefix=DATA

## Verify that R_AARCH64_AUTH_ABS64 against a weak undefined symbol is resolved
## to NULL (plus addend).

# RELA-LABEL: Relocations [
# RELA-NEXT:  ]

# DATA-LABEL: Hex dump of section '.data':
# DATA-NEXT:  0x000302b8 00000000 00000000 10000000 00000000

.weak undef
.hidden undef

.data
foo:
.quad undef@AUTH(da,42)
.quad (undef + 16)@AUTH(da,42)
