const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    _ = b.addModule("any-pointer", .{
        .source_file = .{ .path = "any-pointer.zig" },
    });

    const test_step = b.step("test", "Run library tests");

    const all_modes = std.enums.values(std.builtin.OptimizeMode);
    for (all_modes) |optimize| {
        const main_tests = b.addTest(.{
            .root_source_file = .{ .path = "tests.zig" },
            .optimize = optimize,
        });

        test_step.dependOn(&main_tests.step);
    }

    b.getInstallStep().dependOn(test_step);
}
