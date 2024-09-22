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

var buf: [4096]u8 = undefined;
var available_tasks: [4]data.Task = undefined;

fn show_tasks(req: zap.Request) void {
    var offset: usize = 0;
    var s = std.fmt.bufPrint(buf[offset..],
        \\<html>
        \\{s}
        \\<body>
        \\<table>
        \\<tr>
        \\  <th>name</th><th>description</th>
        \\  <th>individual</th><th>warn_period_sec</th>
        \\  <th>alert_period_sec</th><th>points_value</th>
        \\</tr>
    , .{html_header}) catch return;
    offset += s.len;
    const tasks = data.getTasks(&available_tasks, 1, 4) catch return;
    for (tasks) |task| {
        s = std.fmt.bufPrint(buf[offset..],
            \\<tr>
            \\  <td><a href="/task/edit/{d}">{s}</a></td>
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

//        \\      <label for="individual">Is individual:</label>
//        \\        <input type=checkbox id="individual" value="{}" /><br />

fn edit_task(req: zap.Request, idstr: []const u8) void {
    const id = std.fmt.parseInt(u8, idstr, 10) catch unreachable;
    const tasks = data.getTasks(&available_tasks, id, 1) catch return;
    const task = tasks[0];
    const form_template: []const u8 =
        \\<html>
        \\  <body>
        \\    <h1> Edit task {d} </h1>
        \\    <form>
        \\      <label for="name">Task Name:</label>
        \\        <input type=text id="name" value="{s}" /><br />
        \\      <label for="description">Task Description:</label>
        \\        <input type=text id="description" value="{s}" /><br />
        \\      <label for="warn_period">Task Name:</label>
        \\        <input type=text id="warn_period" value="{d}" /><br />
        \\      <label for="alert_period">Task Name:</label>
        \\        <input type=text id="alert_period" value="{d}" /><br />
        \\      <label for="points_value">Task Name:</label>
        \\        <input type=text id="points_value" value="{d}" /><br />
        \\    </form>
        \\  </body>
        \\</html>;
    ;
    const txt = std.fmt.bufPrint(&buf, form_template, .{
        task.id,
        task.name,
        task.description,
        task.warn_period_sec,
        task.alert_period_sec,
        task.points_value,
    }) catch return;

    req.sendBody(txt) catch return;
}

fn on_request(req: zap.Request) void {
    errdefer |err| {
        if (err == error.http404) {
            req.sendBody("<html><body><h1>For, oh fore<h1></body></html>") catch unreachable;
        } else {
            req.sendBody("<html><body><h1>Unknown error<h1></body></html>") catch unreachable;
        }
    }

    if (req.path) |path| {
        var path_iterator = std.mem.splitScalar(u8, path, '/');
        if ((std.mem.eql(u8, path_iterator.first(), "")) and
            (std.mem.eql(u8, path_iterator.next() orelse "", "task")))
        {
            const op = path_iterator.next() orelse "";
            if (std.mem.eql(u8, op, "show")) {
                show_tasks(req);
            } else if (std.mem.eql(u8, op, "edit")) {
                const idstr = path_iterator.next() orelse "";
                edit_task(req, idstr);
            }
        } else {
            req.sendBody("<html><body><h1>For, oh fore<h1></body></html>") catch return;
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
