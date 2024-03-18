# REQUIRES: aarch64

# RUN: rm -rf %t && split-file %s %t && cd %t

# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu abi-tag1.s -o tag1.o
# RUN: cp tag1.o tag1a.o
# RUN: ld.lld -shared tag1.o tag1a.o -o tagok.so
# RUN: llvm-readelf -n tagok.so | FileCheck --check-prefix OK %s

# OK: AArch64 PAuth ABI tag: platform 0x2a (unknown), version 0x1

# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu abi-tag2.s -o tag2.o
# RUN: not ld.lld tag1.o tag1a.o tag2.o -o /dev/null 2>&1 | FileCheck --check-prefix ERR1 %s

# ERR1:      error: incompatible values of AArch64 PAuth compatibility info found
# ERR1-NEXT: >>> tag1.o: 0x2a000000000000000{{1|2}}00000000000000
# ERR1-NEXT: >>> tag2.o: 0x2a000000000000000{{1|2}}00000000000000

# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu abi-tag-errs.s -o errs.o
# UN: not ld.lld errs.o -o /dev/null 2>&1 | FileCheck --check-prefix ERR2 %s

# ERR2:      error: errs.o:(.note.AARCH64-PAUTH-ABI-tag): invalid type field value 42 (1 expected)
# ERR2-NEXT: error: errs.o:(.note.AARCH64-PAUTH-ABI-tag): invalid name field value XXX (ARM expected)
# ERR2-NEXT: error: errs.o:(.note.AARCH64-PAUTH-ABI-tag): AArch64 PAuth compatibility info is too short (at least 16 bytes expected)

# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu abi-tag-short.s -o short.o
# RUN: not ld.lld short.o -o /dev/null 2>&1 | FileCheck --check-prefix ERR3 %s

# ERR3: error: short.o:(.note.gnu.property+0x0): GNU_PROPERTY_AARCH64_FEATURE_PAUTH entry is too short: expected 16 bytes, but got 12

# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu abi-tag-long.s -o long.o
# RUN: not ld.lld long.o -o /dev/null 2>&1 | FileCheck --check-prefix ERR4 %s

# ERR4: error: long.o:(.note.gnu.property+0x0): GNU_PROPERTY_AARCH64_FEATURE_PAUTH entry is too long: expected 16 bytes, but got 24

# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu abi-tag-multiple.s -o multiple.o
# RUN: not ld.lld multiple.o -o /dev/null 2>&1 | FileCheck --check-prefix ERR5 %s
# ERR5: error: multiple.o:(.note.gnu.property+0x0): multiple GNU_PROPERTY_AARCH64_FEATURE_PAUTH entries are not supported

# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu no-info.s -o noinfo1.o
# RUN: cp noinfo1.o noinfo2.o
# RUN: not ld.lld -z pauth-report=error tag1.o noinfo1.o noinfo2.o -o /dev/null 2>&1 | FileCheck --check-prefix ERR6 %s
# RUN: ld.lld -z pauth-report=warning tag1.o noinfo1.o noinfo2.o -o /dev/null 2>&1 | FileCheck --check-prefix WARN %s
# RUN: ld.lld -z pauth-report=none tag1.o noinfo1.o noinfo2.o --fatal-warnings -o /dev/null

# ERR6:      error: noinfo1.o: -z pauth-report: file does not have AArch64 PAuth compatibility info while tag1.o has one
# ERR6-NEXT: error: noinfo2.o: -z pauth-report: file does not have AArch64 PAuth compatibility info while tag1.o has one
# WARN:      warning: noinfo1.o: -z pauth-report: file does not have AArch64 PAuth compatibility info while tag1.o has one
# WARN-NEXT: warning: noinfo2.o: -z pauth-report: file does not have AArch64 PAuth compatibility info while tag1.o has one

#--- abi-tag-short.s

.section ".note.gnu.property", "a"
.long 4
.long 20
.long 5
.asciz "GNU"
.long 0xc0000001
.long 12
.quad 2
.long 31

#--- abi-tag-long.s

.section ".note.gnu.property", "a"
.long 4
.long 32
.long 5
.asciz "GNU"
.long 0xc0000001
.long 24
.quad 2
.quad 31
.quad 0

#--- abi-tag-multiple.s

.section ".note.gnu.property", "a"
.long 4
.long 48
.long 5
.asciz "GNU"
.long 0xc0000001
.long 16
.quad 42 // platform
.quad 1  // version
.long 0xc0000001
.long 16
.quad 42 // platform
.quad 1  // version

#--- abi-tag-errs.s

.section ".note.AARCH64-PAUTH-ABI-tag", "a"
.long 4
.long 8
.long 42
.asciz "XXX"

.quad 42

#--- abi-tag1.s

.section ".note.gnu.property", "a"
.long 4
.long 24
.long 5
.asciz "GNU"
.long 0xc0000001
.long 16
.quad 42 // platform
.quad 1  // version

#--- abi-tag2.s

.section ".note.gnu.property", "a"
.long 4
.long 24
.long 5
.asciz "GNU"
.long 0xc0000001
.long 16
.quad 42 // platform
.quad 2  // version

#--- no-info.s

## define _start to avoid missing entry warning and use --fatal-warnings to assert no diagnostic
## allow multiple definitions of _start for simplicity
.weak _start;
_start:
