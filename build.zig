const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const target: std.zig.CrossTarget = .{ .os_tag = .windows };
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("vswhom", .{
        .source_file = .{
            .path = "src/lib.zig",
        },
    });

    const lib = b.addStaticLibrary(.{
        .name = "vswhom",
        .target = target,
        .optimize = optimize,
    });
    lib.addCSourceFile("vendor/src/vswhom.cpp", &.{});
    lib.force_pic = true;
    if (optimize == .Debug or optimize == .ReleaseSafe)
        lib.bundle_compiler_rt = true
    else
        lib.strip = true;
    lib.want_lto = false;
    lib.linkSystemLibrary("ole32");
    lib.linkSystemLibrary("oleaut32");
    lib.defineCMacro("LIBEXTERN", null);
    lib.linkLibCpp(); // static-linking w/ LLVM-libcxx (all-platforms) + linking OS-LibC

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(lib);

    const unit_tests = b.addTest(.{
        .name = "vswhom",
        .target = target,
        .optimize = optimize,
        .root_source_file = .{
            .path = "src/lib.zig",
        },
    });
    unit_tests.linkLibrary(lib);
    unit_tests.linkSystemLibrary("ole32");
    unit_tests.linkSystemLibrary("oleaut32");
    unit_tests.linkLibC();

    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}

pub fn module(b: *std.Build) *std.Build.Module {
    return b.createModule(.{
        .source_file = .{
            .path = "src/lib.zig",
        },
    });
}
