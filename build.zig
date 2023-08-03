const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const lib = b.addSharedLibrary("zig-mpv-plugin", "src/plugin.zig", .unversioned);
    lib.linker_allow_shlib_undefined = true;
    lib.linkLibC();
    lib.setTarget(target);
    lib.setBuildMode(mode);

    _ = installArtifact(b, lib, .prefix, "zig-mpv-plugin.so");

    const main_tests = b.addTest("src/plugin.zig");
    main_tests.setTarget(target);
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}

fn installArtifact(b: *std.build.Builder, source: *std.build.LibExeObjStep, install_dir: std.build.InstallDir, dest_rel_path: []const u8) *ArtifactInstallStep {
    const self = b.allocator.create(ArtifactInstallStep) catch unreachable;
    self.* = .{
        .step = std.build.Step.init(.custom, "install library, executable or object to custom location", b.allocator, ArtifactInstallStep.make),
        .builder = b,
        .source = source.getOutputSource(),
        .install_dir = install_dir,
        .dest_rel_path = b.allocator.dupe(u8, dest_rel_path) catch unreachable,
    };
    self.step.dependOn(&source.step);
    b.getInstallStep().dependOn(&self.step);
    return self;
}

const ArtifactInstallStep = struct {
    step: std.build.Step,

    builder: *std.build.Builder,

    source: std.build.FileSource,
    install_dir: std.build.InstallDir,
    dest_rel_path: []const u8,

    fn make(step: *std.build.Step) !void {
        const self = @fieldParentPtr(ArtifactInstallStep, "step", step);
        const b = self.builder;
        const source_path = self.source.getPath(b);
        const dest_path = b.getInstallPath(self.install_dir, self.dest_rel_path);
        try b.updateFile(source_path, dest_path);
    }
};
