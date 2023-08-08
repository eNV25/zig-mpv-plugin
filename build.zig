const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const cc = b.option(bool, "cc", "Use C compiler with Zig's C backend") orelse false;

    const root_source_file = .{ .path = "src/plugin.zig" };

    const cplugin = b.addSharedLibrary(.{
        .name = "plugin",
        .root_source_file = root_source_file,
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    cplugin.target.ofmt = .c;
    cplugin.out_filename = "plugin.c";

    const plugin = b.addSharedLibrary(.{
        .name = "plugin",
        .root_source_file = if (cc) cplugin.getEmittedBin() else root_source_file,
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    plugin.linker_allow_shlib_undefined = true;

    b.getInstallStep().dependOn(&b.addInstallLibFile(plugin.getEmittedBin(), "zig-mpv-plugin/plugin.so").step);

    const tests = b.step("test", "Run tests");
    tests.dependOn(&b.addTest(.{
        .root_source_file = root_source_file,
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    }).step);
}
