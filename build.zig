const std = @import("std");

pub fn build(b: *std.Build) void {
    _ = b.addModule("any-pointer", .{
        .root_source_file = .{ .path = "any-pointer.zig" },
    });

    const test_step = b.step("test", "Run library tests");

    const all_modes = std.enums.values(std.builtin.OptimizeMode);
    for (all_modes) |optimize| {
        const main_tests = b.addTest(.{
            .root_source_file = .{ .path = "tests.zig" },
            .optimize = optimize,
        });

        test_step.dependOn(&b.addRunArtifact(main_tests).step);
    }

    b.getInstallStep().dependOn(test_step);
}
