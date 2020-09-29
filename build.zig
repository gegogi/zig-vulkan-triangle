const std = @import("std");
const os = std.os;
const path = std.fs.path;
const Builder = std.build.Builder;
const builtin = @import("builtin");

pub fn build(b: *Builder) !void {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("tri", "src/main.zig");
    exe.setBuildMode(mode);
    switch (builtin.os.tag) {
        .windows => {
            exe.linkSystemLibrary("user32");
            exe.linkSystemLibrary("kernel32");
            exe.linkSystemLibrary("gdi32");
            exe.linkSystemLibrary("shell32");

            exe.addIncludeDir("D:\\Code1\\VulkanSDK\\1.2.148.1\\Include");
            exe.addLibPath("D:\\Code1\\VulkanSDK\\1.2.148.1\\Lib");
            exe.linkSystemLibrary("vulkan-1");

            exe.addIncludeDir("D:\\Code\\vcpkg\\installed\\x64-windows-static\\include");
            exe.addLibPath("D:\\Code\\vcpkg\\installed\\x64-windows-static\\lib");
            exe.linkSystemLibrary("glfw3");
        },
        else => {
            exe.linkSystemLibrary("glfw");
            exe.linkSystemLibrary("vulkan");
        },
    }

    exe.linkSystemLibrary("c");

    // STB
    //exe.addCSourceFile("deps/stb_image/src/stb_image_impl.c", &[_][]const u8{"-std=c99"});
    //exe.addIncludeDir("deps/stb_image/include");

    // GLAD
    //exe.addCSourceFile("deps/glad/src/glad.c", &[_][]const u8{"-std=c99"});
    //exe.addIncludeDir("deps/glad/include");

    exe.install();

    b.default_step.dependOn(&exe.step);

    const run_step = b.step("run", "Run the app");
    const run_cmd = exe.run();
    run_step.dependOn(&run_cmd.step);

    try addShader(b, exe, "shader.vert", "vert.spv");
    try addShader(b, exe, "shader.frag", "frag.spv");
}

fn addShader(b: *Builder, exe: anytype, in_file: []const u8, out_file: []const u8) !void {
    // example:
    // glslc -o shaders/vert.spv shaders/shader.vert
    const dirname = "shaders";
    const full_in = try path.join(b.allocator, &[_][]const u8{ dirname, in_file });
    const full_out = try path.join(b.allocator, &[_][]const u8{ dirname, out_file });

    const run_cmd = b.addSystemCommand(&[_][]const u8{
        "glslc",
        "-o",
        full_out,
        full_in,
    });
    exe.step.dependOn(&run_cmd.step);
}
