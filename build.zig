const std = @import("std");

pub fn build(b: *std.Build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const cc = b.option(bool, "cc", "Use C compiler with Zig's C backend") orelse false;

    const ctarget = ctarget: {
        var ctarget = target;
        ctarget.ofmt = .c;
        break :ctarget ctarget;
    };

    const plugin_zig_source_file = std.Build.LazyPath{ .path = "src/plugin.zig" };
    const plugin_source_file = if (cc) b.addObject(.{
        .name = "cplugin",
        .root_source_file = plugin_zig_source_file,
        .target = ctarget,
        .optimize = optimize,
        .link_libc = true,
    }).getEmittedBin() else plugin_zig_source_file;

    const plugin = b.addSharedLibrary(.{
        .name = "plugin",
        .root_source_file = plugin_source_file,
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    plugin.linker_allow_shlib_undefined = true;

    b.getInstallStep().dependOn(&b.addInstallLibFile(plugin.getEmittedBin(), "zig-mpv-plugin/plugin.so").step);
}
