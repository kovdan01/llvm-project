// RUN: %clang_cc1 -triple arm64-apple-ios -S -verify -fptrauth-intrinsics %s -fexperimental-new-constant-interpreter

typedef __UINTPTR_TYPE__ uintptr_t;

void callee(uintptr_t disc);

uintptr_t test_blend_can_only_be_used_as_argument_of_ptrauth_intrinsic(int *dp) {
  (void)__builtin_ptrauth_blend_discriminator(dp, 1); // expected-error {{Standalone blend builtin is not supported}}
  uintptr_t tmp1 = __builtin_ptrauth_blend_discriminator(dp, 2); // expected-error {{Standalone blend builtin is not supported}}
  int *tmp2 = __builtin_ptrauth_sign_unauthenticated(dp, 0, tmp1);
  callee(__builtin_ptrauth_blend_discriminator(dp, 3)); // expected-error {{Standalone blend builtin is not supported}}
  return __builtin_ptrauth_blend_discriminator(dp, 4); // expected-error {{Standalone blend builtin is not supported}}
}
