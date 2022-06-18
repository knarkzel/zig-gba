const std = @import("std");

const devkitpro = "/opt/devkitpro";

pub fn build(b: *std.build.Builder) void {
    const mode = b.standardReleaseOptions();

    const obj = b.addObject("zig-gba", "src/main.zig");
    obj.setOutputDir("zig-out");
    obj.linkLibC();
    obj.setLibCFile(std.build.FileSource{ .path = "libc.txt" });
    obj.addIncludeDir(devkitpro ++ "/libgba/include");
    obj.setTarget(.{
        .cpu_arch = .thumb,
        .os_tag = .freestanding,
        .abi = .eabi,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.arm7tdmi },
    });
    obj.setBuildMode(mode);

    const elf = b.addSystemCommand(&.{
        devkitpro ++ "/devkitARM/bin/arm-none-eabi-gcc",
        "-g",
        "-mthumb",
        "-mthumb-interwork",
        "-Wl,-Map,zig-out/zig-gba.map",
        "-specs=gba.specs",
        "zig-out/zig-gba.o",
        "-L" ++ devkitpro ++ "/libgba/lib",
        "-lmm",
        "-lgba",
        "-o",
        "zig-out/zig-gba.elf",
    });

    const gba = b.addSystemCommand(&.{
        devkitpro ++ "/devkitARM/bin/arm-none-eabi-objcopy",
        "-O",
        "binary",
        "zig-out/zig-gba.elf",
        "zig-out/zig-gba.gba",
    });

    const fix = b.addSystemCommand(&.{
        devkitpro ++ "/tools/bin/gbafix",
        "zig-out/zig-gba.gba",
    });

    b.default_step.dependOn(&fix.step);
    fix.step.dependOn(&gba.step);
    gba.step.dependOn(&elf.step);
    elf.step.dependOn(&obj.step);
}
