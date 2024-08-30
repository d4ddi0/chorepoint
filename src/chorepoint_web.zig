const std = @import("std");
const zap = @import("zap");

var listener = zap.HttpListener.init(.{
    .port = 3000,
    .on_request = on_request,
    .log = true,
    .max_clients = 1000,
});

fn on_request(req: zap.Request) void {
    req.sendBody("<html><body><h1>Hello from ZAP!!!</h1></body></html>") catch return;
}

pub fn init() void {}

pub fn deinit() void {}

pub fn start() !void {
    try listener.listen();
}
