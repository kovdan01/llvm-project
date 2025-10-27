//===----- CGPointerAuthInfo.h -  -------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Pointer auth info class.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_LIB_CODEGEN_CGPOINTERAUTHINFO_H
#define LLVM_CLANG_LIB_CODEGEN_CGPOINTERAUTHINFO_H

#include "clang/Basic/LangOptions.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/Value.h"
#include <tuple>

namespace clang {
namespace CodeGen {

class CGPointerAuthInfo {
public:
  CGPointerAuthInfo()
      : AuthenticationMode(PointerAuthenticationMode::None),
        IsIsaPointer(false), AuthenticatesNullValues(false), Key(0),
        Discriminator(nullptr), ExtraDiscriminator(nullptr) {}
  CGPointerAuthInfo(unsigned Key, PointerAuthenticationMode AuthenticationMode,
                    bool IsIsaPointer, bool AuthenticatesNullValues,
                    llvm::Value *Discriminator, llvm::Value *ExtraDiscriminator)
      : AuthenticationMode(AuthenticationMode), IsIsaPointer(IsIsaPointer),
        AuthenticatesNullValues(AuthenticatesNullValues), Key(Key),
        Discriminator(Discriminator), ExtraDiscriminator(ExtraDiscriminator) {
    assert(!Discriminator || Discriminator->getType()->isIntegerTy() ||
           Discriminator->getType()->isPointerTy());
    assert(!ExtraDiscriminator || ExtraDiscriminator->getType()->isIntegerTy());

    if (!Discriminator) {
      this->Discriminator = ExtraDiscriminator;
      this->ExtraDiscriminator = nullptr;
    }
  }

  explicit operator bool() const { return isSigned(); }

  bool isSigned() const {
    return AuthenticationMode != PointerAuthenticationMode::None;
  }

  unsigned getKey() const {
    assert(isSigned());
    return Key;
  }

  llvm::Value *getDiscriminator() const {
    assert(isSigned());
    return Discriminator;
  }

  llvm::Value *getExtraDiscriminator() const {
    assert(isSigned());
    return ExtraDiscriminator;
  }

  PointerAuthenticationMode getAuthenticationMode() const {
    return AuthenticationMode;
  }

  bool isIsaPointer() const { return IsIsaPointer; }

  bool authenticatesNullValues() const { return AuthenticatesNullValues; }

  bool shouldStrip() const {
    return AuthenticationMode == PointerAuthenticationMode::Strip ||
           AuthenticationMode == PointerAuthenticationMode::SignAndStrip;
  }

  bool shouldSign() const {
    return AuthenticationMode == PointerAuthenticationMode::SignAndStrip ||
           AuthenticationMode == PointerAuthenticationMode::SignAndAuth;
  }

  bool shouldAuth() const {
    return AuthenticationMode == PointerAuthenticationMode::SignAndAuth;
  }

  bool isBlended() const { return ExtraDiscriminator != nullptr; }

  friend bool operator!=(const CGPointerAuthInfo &LHS,
                         const CGPointerAuthInfo &RHS) {
    return !(LHS == RHS);
  }

  friend bool operator==(const CGPointerAuthInfo &LHS,
                         const CGPointerAuthInfo &RHS) {
    auto AsTuple = [](const CGPointerAuthInfo &Info) {
      return std::make_tuple(Info.AuthenticationMode, Info.IsIsaPointer,
                             Info.AuthenticatesNullValues, Info.Key,
                             Info.Discriminator, Info.ExtraDiscriminator);
    };
    return AsTuple(LHS) == AsTuple(RHS);
  }

private:
  PointerAuthenticationMode AuthenticationMode : 2;
  unsigned IsIsaPointer : 1;
  unsigned AuthenticatesNullValues : 1;
  unsigned Key : 2;
  llvm::Value *Discriminator;
  llvm::Value *ExtraDiscriminator;
};

} // end namespace CodeGen
} // end namespace clang

#endif
