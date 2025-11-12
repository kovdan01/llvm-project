// RUN: %clang_cc1 -triple arm64-apple-ios -fptrauth-calls -emit-llvm -fexceptions -fptrauth-intrinsics -o - %s | FileCheck %s

typedef void (*func)();

__attribute__((objc_root_class))
@interface Root {
  Class isa;
  void *__ptrauth(1, 1, 1) _field1;
  void *__ptrauth(1, 1, 1) _field2;
  func __ptrauth(1, 1, 1) _field3;
  func __ptrauth(1, 1, 123) _field4;
}

@property void *field1;
@property(nonatomic) void *field2;
@property func field3;
@property(nonatomic) func field4;
@end

@implementation Root
@end

// CHECK-LABEL: define internal ptr @"\01-[Root field1]"
// CHECK: [[LOAD:%.*]] = load atomic i64, ptr [[ADDR:%.*]] unordered
// CHECK: [[CAST_ADDR:%.*]] = ptrtoint ptr [[ADDR]] to i64
// CHECK: [[RESULT:%.*]] = call i64 @llvm.ptrauth.auth(i64 [[LOAD]]) [ "ptrauth"(i64 1, i64 1, i64 [[CAST_ADDR]]) ]

// CHECK-LABEL: define internal void @"\01-[Root setField1:]"
// CHECK: [[CAST_ADDR:%.*]] = ptrtoint ptr [[ADDR:%.*]] to i64
// CHECK: [[RESULT:%.*]] = call i64 @llvm.ptrauth.sign(i64 [[VALUE:%.*]]) [ "ptrauth"(i64 1, i64 1, i64 [[CAST_ADDR]]) ]
// CHECK: [[PHI:%.*]] = phi i64 [ 0, {{%.*}} ], [ [[RESULT]], {{%.*}} ]
// CHECK: store atomic i64 [[PHI]], ptr [[ADDR]] unordered

// CHECK-LABEL: define internal ptr @"\01-[Root field2]"
// CHECK: load ptr, ptr
// CHECK: [[LOAD:%.*]] = load ptr, ptr [[ADDR:%.*]],
// CHECK: [[CAST_ADDR:%.*]] = ptrtoint ptr [[ADDR]] to i64
// CHECK: [[VALUE:%.*]] = ptrtoint ptr [[LOAD]] to i64
// CHECK: [[RESULT:%.*]] = call i64 @llvm.ptrauth.auth(i64 [[VALUE]]) [ "ptrauth"(i64 1, i64 1, i64 [[CAST_ADDR:%.*]]) ]

// CHECK-LABEL: define internal void @"\01-[Root setField2:]"
// CHECK: [[CAST_ADDR:%.*]] = ptrtoint ptr [[ADDR:%.*]] to i64
// CHECK: [[CAST_VALUE:%.*]] = ptrtoint ptr [[VALUE:%.*]] to i64
// CHECK: [[SIGNED:%.*]] = call i64 @llvm.ptrauth.sign(i64 [[CAST_VALUE]]) [ "ptrauth"(i64 1, i64 1, i64 [[CAST_ADDR]]) ]
// CHECK: [[RESULT:%.*]] = inttoptr i64 [[SIGNED]] to ptr
// CHECK: [[PHI:%.*]] = phi ptr [ null, {{%.*}} ], [ [[RESULT]], {{%.*}} ]
// CHECK: store ptr [[PHI]], ptr [[ADDR]]

// CHECK-LABEL: define internal ptr @"\01-[Root field3]"
// CHECK: [[VALUE:%.*]] = load atomic i64, ptr [[ADDR:%.*]] unordered, align 8
// CHECK: [[CASTED_ADDR:%.*]] = ptrtoint ptr [[ADDR]] to i64
// CHECK: {{%.*}} = call i64 @llvm.ptrauth.resign(i64 [[VALUE]]) [ "ptrauth"(i64 1, i64 1, i64 [[CASTED_ADDR]]), "ptrauth"(i64 0, i64 0, i64 0) ]

// CHECK-LABEL: define internal void @"\01-[Root setField3:]"
// CHECK: [[VALUE:%.*]] = load i64, ptr {{%.*}}, align 8
// CHECK: [[CASTED_ADDR:%.*]] = ptrtoint ptr {{%.*}} to i64
// CHECK: {{%.*}} = call i64 @llvm.ptrauth.resign(i64 [[VALUE]]) [ "ptrauth"(i64 0, i64 0, i64 0), "ptrauth"(i64 1, i64 1, i64 [[CASTED_ADDR]]) ]
// CHECK: store atomic i64

// CHECK-LABEL: define internal ptr @"\01-[Root field4]"
// CHECK: load ptr, ptr
// CHECK: [[VALUE:%.*]] = load ptr, ptr [[ADDR:%.*]],
// CHECK: [[CASTED_ADDR:%.*]] = ptrtoint ptr [[ADDR]] to i64
// CHECK: [[CAST_VALUE:%.*]] = ptrtoint ptr [[VALUE]] to i64
// CHECK: {{%.*}} = call i64 @llvm.ptrauth.resign(i64 [[CAST_VALUE]]) [ "ptrauth"(i64 1, i64 123, i64 [[CASTED_ADDR]]), "ptrauth"(i64 0, i64 0, i64 0) ]

// CHECK-LABEL: define internal void @"\01-[Root setField4:]"
// CHECK: [[CAST_ADDR:%.*]] = ptrtoint ptr {{%.*}} to i64
// CHECK: resign.nonnull:
// CHECK: [[VALUE:%.*]] = ptrtoint ptr %1 to i64
// CHECK: {{%.*}} = call i64 @llvm.ptrauth.resign(i64 [[VALUE]]) [ "ptrauth"(i64 0, i64 0, i64 0), "ptrauth"(i64 1, i64 123, i64 [[CAST_ADDR]]) ]

