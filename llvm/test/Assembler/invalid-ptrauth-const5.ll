; RUN: not llvm-as < %s 2>&1 | FileCheck %s

@var = global i32 0

; CHECK: error: signed pointer discriminator must be i16 constant integer
@auth_var = global i32* ptrauth (i32* @var, i32 2, i8* null, i16 ptrtoint(i32* @var to i16))
