const std = @import("std");
const lib = @import("any-pointer.zig");

const AnyPointer = lib.AnyPointer;
const SafePointer = lib.SafePointer;
const UnsafePointer = lib.UnsafePointer;

test "basic safe pointer" {
    var i: u32 = 0;

    const erased = SafePointer.make(*u32, &i);

    const ptr = erased.cast(*u32);

    try std.testing.expectEqual(@as(*u32, &i), ptr);

    ptr.* = 42;

    std.debug.assert(i == 42);
}

test "basic unsafe pointer" {
    var i: u32 = 0;

    const erased = UnsafePointer.make(*u32, &i);

    const ptr = erased.cast(*u32);

    try std.testing.expectEqual(@as(*u32, &i), ptr);

    ptr.* = 42;

    std.debug.assert(i == 42);
}

test "safe pointer try cast" {
    var i: u32 = 0;

    const erased = SafePointer.make(*u32, &i);

    try std.testing.expectEqual(@as(?*u32, &i), erased.tryCast(*u32));
    try std.testing.expectEqual(@as(?*f32, null), erased.tryCast(*f32));
}

test "optional pointer" {
    var i: u32 = 0;

    const erased = AnyPointer.make(?*u32, &i);

    const ptr = erased.cast(?*u32);

    try std.testing.expectEqual(@as(?*u32, &i), ptr);

    ptr.?.* = 42;

    std.debug.assert(i == 42);
}

test "tryCast optional pointer" {
    var i: u32 = 0;

    const erased = SafePointer.make(?*u32, &i);

    try std.testing.expectEqual(@as(??*u32, &i), erased.tryCast(?*u32));
    try std.testing.expectEqual(@as(??*f32, null), erased.tryCast(?*f32));
}

test "unsafe null pointer" {
    const erased = UnsafePointer.null_pointer;
    try std.testing.expectEqual(true, erased.isNull());
}

test "safe null pointer" {
    const erased = SafePointer.null_pointer;
    try std.testing.expectEqual(true, erased.isNull());
}

// test "failing test: type mismatch" {
//     var i: u32 = 0;

//     const erased = SafePointer.make(*u32, &i);

//     const ptr = erased.cast(*f32);

//     ptr.* = 42;

//     std.debug.assert(i == 42);
// }
