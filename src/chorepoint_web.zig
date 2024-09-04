const std = @import("std");
const zap = @import("zap");
const data = @import("chorepoint_data.zig");

fn show_tasks(req: zap.Request) void {
    var buf: [256]u8 = undefined;
    const s = std.fmt.bufPrint(&buf, "<html><body><h1>{s}<h1></body></html>", .{data.pr_tasks()}) catch return;
    req.sendBody(s) catch return;
}

var listener = zap.HttpListener.init(.{
    .port = 3000,
    .on_request = on_request,
    .log = true,
    .max_clients = 1000,
});

fn on_request(req: zap.Request) void {
    if (req.path) |path| {
        if (std.mem.eql(u8, "/task/show", path)) {
            show_tasks(req);
        } else {
            req.sendBody("<html><body><h1>Four oh four<h1></body></html>") catch return;
        }
        return;
    }
    req.sendBody("<html><body><h1>Hello from ZAP!!!</h1></body></html>") catch return;
}

pub fn init() void {
    std.debug.print("Initializing Chorepoint\n", .{});
}

pub fn uninit() void {
    std.debug.print("Uninitializing Chorepoint\n", .{});
}

pub fn start() !void {
    try listener.listen();
    zap.start(.{
        .threads = 2,
        .workers = 2,
    });
}
