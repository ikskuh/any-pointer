const std = @import("std");
const lib = @import("any-pointer.zig");
const builtin = @import("builtin");

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

test "unsafe address equality" {
    var i: u32 = 0;
    var j: u32 = 0;

    const erased = UnsafePointer.make(*u32, &i);
    const erased_same = UnsafePointer.make(*u32, &i);
    const erased_other = UnsafePointer.make(*u32, &j);
    const erased_null = UnsafePointer.null_pointer;

    try std.testing.expectEqual(true, erased.eql(erased_same));
    try std.testing.expectEqual(false, erased.eql(erased_other));

    try std.testing.expectEqual(true, erased_null.eql(UnsafePointer.null_pointer));
    try std.testing.expectEqual(false, erased.eql(UnsafePointer.null_pointer));
}

test "safe address equality" {
    var i: u32 = 0;
    var j: u32 = 0;

    const erased = SafePointer.make(*u32, &i);
    const erased_same = SafePointer.make(*u32, &i);
    const erased_other = SafePointer.make(*u32, &j);
    const erased_null = SafePointer.null_pointer;

    try std.testing.expectEqual(true, erased.eql(erased_same));
    try std.testing.expectEqual(false, erased.eql(erased_other));

    try std.testing.expectEqual(true, erased_null.eql(SafePointer.null_pointer));
    try std.testing.expectEqual(false, erased.eql(SafePointer.null_pointer));
}

fn failingTest() void {
    var i: u32 = 0;

    const erased = SafePointer.make(*u32, &i);

    const ptr = erased.cast(*f32);

    ptr.* = 42;

    std.debug.assert(i == 42);
}

test "failing test: type mismatch" {
    if (builtin.os.tag == .windows) {
        return error.ZigSkipTest;
    } else {
        var pid = try std.os.fork();
        if (pid == 0) {
            std.os.close(std.os.STDOUT_FILENO);
            std.os.close(std.os.STDERR_FILENO);
            failingTest();
            std.os.exit(0);
        }
        const res = std.os.waitpid(pid, 0);
        try std.testing.expectEqual(pid, res.pid);
        try std.testing.expect(res.status != 0);
    }
}
