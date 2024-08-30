const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "chorepoint",
        .root_source_file = b.path("chorepoint.zig"),
        .target = b.host,
    });
    const zap = b.dependency("zap", .{
        .target = target,
        .optimize = optimize,
        .openssl = false, // set to true to enable TLS support
    });

    exe.linkLibC();
    exe.linkSystemLibrary("sqlite3");
    exe.root_module.addImport("zap", zap.module("zap"));

    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Do the thing");
    run_step.dependOn(&run_exe.step);
}
