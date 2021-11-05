const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const test_step = b.step("test", "Run library tests");

    const all_modes = std.enums.values(std.builtin.Mode);
    for (all_modes) |mode| {
        const main_tests = b.addTest("tests.zig");
        main_tests.setBuildMode(mode);

        test_step.dependOn(&main_tests.step);
    }

    b.getInstallStep().dependOn(test_step);
}
