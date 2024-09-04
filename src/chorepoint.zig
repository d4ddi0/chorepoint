const std = @import("std");
const web = @import("chorepoint_web.zig");
const data = @import("chorepoint_data.zig");

pub fn main() !void {
    try data.init();
    defer data.shutdown();
    web.init();
    defer web.uninit();
    try web.start();
}
