const c = @import("c.zig");

export fn main(argc: c_int, argv: [*]const [*:0]const u8) void {
    _ = argc;
    _ = argv;
    c.irqInit();
    c.irqEnable(c.IRQ_VBLANK);
    c.consoleDemoInit();

    _ = c.printf("Hello, world!");
    while (true) {
        // c.VBlankIntrWait();
    }
}
