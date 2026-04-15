const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("any-pointer", .{
        .root_source_file = b.path("any-pointer.zig"),
        .target = target,
        .optimize = optimize,
    });

    const test_step = b.step("test", "Run library tests");

    const main_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("tests.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const run_main_tests = b.addRunArtifact(main_tests);
    test_step.dependOn(&run_main_tests.step);

    const type_mismatch_test = b.addExecutable(.{
        .name = "type_mismatch_test",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tests/type_mismatch.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "any-pointer", .module = mod },
            },
        }),
    });
    const run_type_mismatch_test = b.addRunArtifact(type_mismatch_test);
    switch (optimize) {
        .Debug => run_type_mismatch_test.addCheck(.{ .expect_stderr_match = "Type mismatch: Expected *f32, but got *u32!" }),
        else => run_type_mismatch_test.addCheck(.{ .expect_stderr_match = "Type mismatch: Expected *f32, but got <unknown>!" }),
    }
    test_step.dependOn(&run_type_mismatch_test.step);
}
