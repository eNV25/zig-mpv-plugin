const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const plugin = b.addSharedLibrary("zig-mpv-plugin", "src/plugin.zig", .unversioned);
    plugin.linker_allow_shlib_undefined = true;
    plugin.linkLibC();
    plugin.setTarget(target);
    plugin.setBuildMode(mode);

    const plugin_install = b.addInstallFileWithDir(plugin.getOutputSource(), .lib, "zig-mpv-plugin/plugin.so");
    plugin_install.step.dependOn(&plugin.step);
    b.getInstallStep().dependOn(&plugin_install.step);

    const main_tests = b.addTest("src/plugin.zig");
    main_tests.setTarget(target);
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}
