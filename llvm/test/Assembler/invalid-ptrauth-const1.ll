; RUN: not llvm-as < %s 2>&1 | FileCheck %s

@var = global i32 0

; CHECK: error: signed pointer must be a pointer
@auth_var = global i32* ptrauth (i32 42, i32 0, i8* null, i16 65535)
