const std = @import("std");
const builtin = @import("builtin");

const is_safe_mode = switch (builtin.mode) {
    .Debug, .ReleaseSafe => true,
    .ReleaseFast, .ReleaseSmall => false,
};

const AnyPointer = if (is_safe_mode)
    SafePointer
else
    UnsafePointer;

pub const SafePointer = struct {
    pub const null_pointer = SafePointer{ .address = 0, .type_id = @intToEnum(TypeId, 0) };

    address: usize,
    type_id: TypeId,

    pub fn make(comptime T: type, ptr: T) SafePointer {
        assertPointer(T);
        return SafePointer{
            .address = @ptrToInt(ptr),
            .type_id = typeId(T),
        };
    }

    pub fn cast(self: SafePointer, comptime T: type) T {
        assertPointer(T);
        if (typeId(T) != self.type_id) {
            if (builtin.mode == .Debug) {
                std.debug.panic("Type mismatch: Expected {s}, but got {s}!", .{ @typeName(T), self.type_id.name() });
            } else {
                std.debug.panic("Type mismatch: Expected {s}, but got <unknown>!", .{@typeName(T)});
            }
        }
        return @intToPtr(T, self.address);
    }
};

pub const UnsafePointer = enum(usize) {
    null_pointer,
    _,

    pub fn make(comptime T: type, ptr: T) UnsafePointer {
        assertPointer(T);
        return @intToEnum(UnsafePointer, @ptrToInt(ptr));
    }

    pub fn cast(self: UnsafePointer, comptime T: type) T {
        assertPointer(T);
        return @intToPtr(T, @enumToInt(self));
    }
};

const TypeId = enum(usize) {
    _,

    pub fn name(self: TypeId) []const u8 {
        if (builtin.mode == .Debug) {
            return std.mem.sliceTo(@intToPtr([*:0]const u8, @enumToInt(self)), 0);
        } else {
            @compileError("Cannot use TypeId.name outside of Debug mode!");
        }
    }
};

fn assertPointer(comptime T: type) void {
    comptime var ti: std.builtin.TypeInfo = @typeInfo(T);
    if (ti == .Optional) {
        ti = @typeInfo(ti.Optional.child);
    }
    if (ti != .Pointer)
        @compileError("any-pointer only works with (optional) pointers to one or many.");
    switch (ti.Pointer.size) {
        .One, .Many, .C => {},
        else => @compileError("any-pointer only works with (optional) pointers to one or many."),
    }
}

fn typeId(comptime T: type) TypeId {
    const Tag = if (builtin.mode == .Debug)
        struct {
            const str = @typeName(T);
            var name: [str.len:0]u8 = str.*;
        }
    else
        struct {
            var name: u8 = 0;
        };
    return @intToEnum(TypeId, @ptrToInt(&Tag.name));
}

test "basic  pointer test" {
    var i: u32 = 0;

    const erased = AnyPointer.make(*u32, &i);

    const ptr = erased.cast(*u32);

    ptr.* = 42;

    std.debug.assert(i == 42);
}

test "basic safe pointer test" {
    var i: u32 = 0;

    const erased = SafePointer.make(*u32, &i);

    const ptr = erased.cast(*u32);

    ptr.* = 42;

    std.debug.assert(i == 42);
}

test "basic unsafe pointer test" {
    var i: u32 = 0;

    const erased = UnsafePointer.make(*u32, &i);

    const ptr = erased.cast(*u32);

    ptr.* = 42;

    std.debug.assert(i == 42);
}

// test "failing test: type mismatch" {
//     var i: u32 = 0;

//     const erased = SafePointer.make(*u32, &i);

//     const ptr = erased.cast(*f32);

//     ptr.* = 42;

//     std.debug.assert(i == 42);
// }
