const std = @import("std");
const sqlite = @cImport(@cInclude("sqlite3.h"));

// database struct
var db: ?*sqlite.sqlite3 = null;

const TextBuf = struct {
    buf: []u8,
    pos: usize = 0,
};

fn tbufPrint(tbuf: *TextBuf, comptime fmt: []const u8, args: anytype) !void {
    const slice: [:0]u8 = try std.fmt.bufPrintZ(tbuf.*.buf[tbuf.*.pos..], fmt, args);
    std.debug.print(fmt, args);
    tbuf.*.pos += slice.len;
}

fn pr_table_header(tbuf: *TextBuf, argc: c_int, names: [*c][*c]u8) !void {
    try tbufPrint(tbuf, "<tr>", .{});
    var i: usize = 0;
    while (i < argc) {
        try tbufPrint(tbuf, "<th>{s}</th>", .{names[i]});
        i += 1;
    }
    try tbufPrint(tbuf, "</tr>\n", .{});
}

export fn pr_task(data: ?*anyopaque, argc: c_int, argv: [*c][*c]u8, names: [*c][*c]u8) i32 {
    const tbuf: *TextBuf = @alignCast(@ptrCast(data));
    if (tbuf.*.pos == 0) {
        pr_table_header(tbuf, argc, names) catch {
            std.debug.print("error in pr_table_header\n", .{});
            return sqlite.SQLITE_ERROR;
        };
    }
    tbufPrint(tbuf, "<tr>", .{}) catch return sqlite.SQLITE_ERROR;
    var i: usize = 0;
    while (i < argc) {
        if (argv[i] == null) {
            tbufPrint(tbuf, "<td>NULL</td>", .{}) catch return sqlite.SQLITE_ERROR;
        } else {
            tbufPrint(tbuf, "<td>{s}</td>", .{argv[i]}) catch return sqlite.SQLITE_ERROR;
        }
        i += 1;
    }
    tbufPrint(tbuf, "</tr>\n", .{}) catch return sqlite.SQLITE_ERROR;
    return sqlite.SQLITE_OK;
}

pub fn pr_tasks(txt: []u8) []u8 {
    const select_stmt = "SELECT * FROM task;";
    var tbuf = TextBuf{ .buf = txt };
    var err_msg: [*c]u8 = undefined;
    const result = sqlite.sqlite3_exec(db, select_stmt, pr_task, &tbuf, &err_msg);
    defer sqlite.sqlite3_free(err_msg);
    if (result != sqlite.SQLITE_OK) {
        std.debug.print("Error getting tasks: {s}\n", .{err_msg});
    }
    return tbuf.buf[0..tbuf.pos];
}

pub fn init() !void {
    var result = sqlite.sqlite3_open("chorepoint.dat", &db);
    if (result != sqlite.SQLITE_OK) {
        std.debug.print("Error opening db: {s}\n", .{sqlite.sqlite3_errmsg(db)});
        const close_result = sqlite.sqlite3_close(db);
        if (close_result != sqlite.SQLITE_OK) {
            std.debug.print("Error closing db: {s}\n", .{sqlite.sqlite3_errmsg(db)});
        }
        return error.sqliteOpenError;
    }

    const create_stmt =
        \\CREATE TABLE IF NOT EXISTS task (
        \\id INT PRIMARY KEY
        \\,name TEXT
        \\,description TEXT
        \\,individual INT
        \\,warn_period_sec INT
        \\,alert_period_sec INT
        \\,points_value INT
        \\);
        //INSERT INTO task (name, description, individual, points_value)
        //VALUES('Dishes', 'Wash the dishes', FALSE, 500);
    ;
    var err_msg: [*c]u8 = undefined;
    result = sqlite.sqlite3_exec(db, create_stmt, null, null, &err_msg);
    if (err_msg) |msg| {
        if (result != sqlite.SQLITE_OK) {
            std.debug.print("Error creating task table: {s}\n", .{msg});
        }
    }
}

pub fn shutdown() void {
    const result = sqlite.sqlite3_close(db);
    if (result != sqlite.SQLITE_OK) {
        std.debug.print("aargh on close!\n", .{});
    }
}
