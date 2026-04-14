const std = @import("std");
const any_pointer = @import("any-pointer");

pub fn main() void {
    var i: u32 = 0;

    const erased = any_pointer.SafePointer.make(*u32, &i);

    const ptr = erased.cast(*f32);

    ptr.* = 42;

    std.debug.assert(i == 42);
}
