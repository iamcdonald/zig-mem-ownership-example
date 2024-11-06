const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Dependencies

    // Tests
    const test_filters: []const []const u8 = b.option(
        []const []const u8,
        "test-filter",
        "Skip tests that do not match any of the specified filters",
    ) orelse &.{};
    const force: bool = b.option(
        bool,
        "force",
        "Ignore test cache",
    ) orelse false;
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .filters = test_filters,
    });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    run_lib_unit_tests.has_side_effects = force;
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);

    // ZLS comp check
    const lib_zls_check = b.addStaticLibrary(.{
        .name = "lib",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const lib_zls_test_check = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const check = b.step("check", "Check if lib compiles");
    check.dependOn(&lib_zls_check.step);
    check.dependOn(&lib_zls_test_check.step);
}
