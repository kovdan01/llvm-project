; RUN: llvm-as < %s | llvm-dis | FileCheck %s

@var = global i32 0

; CHECK: @auth_var = global ptr ptrauth (ptr @var, i32 0, ptr null, i16 -1)
@auth_var = global i32* ptrauth (i32* @var, i32 0, i8* null, i16 65535)


; CHECK: @addrdisc_var = global ptr ptrauth (ptr @var, i32 0, ptr @addrdisc_var, i16 1234)
@addrdisc_var = global i32* ptrauth (i32* @var, i32 0, i32** @addrdisc_var, i16 1234)

; CHECK: @keyed_var = global ptr ptrauth (ptr @var, i32 3, ptr null, i16 0)
@keyed_var = global i32* ptrauth (i32* @var, i32 3, i8* null, i16 0)
