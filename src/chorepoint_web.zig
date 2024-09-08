const std = @import("std");
const zap = @import("zap");
const data = @import("chorepoint_data.zig");

const html_header =
    \\<head><style>
    \\table, th, td {
    \\    border: 1px solid black;
    \\    border-collapse: collapse
    \\}
    \\</style></head>\n
;

fn show_tasks(req: zap.Request) void {
    var buf: [4096]u8 = undefined;
    var offset: usize = 0;
    var s = std.fmt.bufPrint(buf[offset..],
        \\<html>
        \\{s}
        \\<body>
        \\<table>
        \\<tr>
        \\  <th>id</th><th>name</th><th>description</th>
        \\  <th>individual</th><th>warn_period_sec</th>
        \\  <th>alert_period_sec</th><th>points_value</th>
        \\</tr>
    , .{html_header}) catch return;
    offset += s.len;
    var available_tasks: [4]data.Task = undefined;
    const tasks = data.getTasks(&available_tasks) catch return;
    for (tasks) |task| {
        s = std.fmt.bufPrint(buf[offset..],
            \\<tr>
            \\  <td>{d}</td>
            \\  <td>{s}</td>
            \\  <td>{s}</td>
            \\  <td>{?}</td>
            \\  <td>{d}</td>
            \\  <td>{d}</td>
            \\  <td>{d}</td>
            \\</tr>
        , .{
            task.id,
            task.name,
            task.description,
            task.individual,
            task.warn_period_sec,
            task.alert_period_sec,
            task.points_value,
        }) catch break;
        offset += s.len;
    }
    s = std.fmt.bufPrint(buf[offset..], "</table></body></html>", .{}) catch return;
    req.sendBody(buf[0..offset]) catch return;
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
