; RUN: not llvm-as < %s 2>&1 | FileCheck %s

@var = global i32 0

; CHECK: error: signed pointer key must be i32 constant integer
@auth_var = global i32* ptrauth (i32* @var, i32 ptrtoint(i32* @var to i32), i8* null, i16 65535)
