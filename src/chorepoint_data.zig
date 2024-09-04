const std = @import("std");
const sqlite = @cImport(@cInclude("sqlite3.h"));

// database struct
var db: ?*sqlite.sqlite3 = null;

export fn pr_task(data: ?*anyopaque, argc: c_int, argv: [*c][*c]u8, names: [*c][*c]u8) i32 {
    const buf: *[128]u8 = @ptrCast(data);
    _ = std.fmt.bufPrintZ(buf, "<tr><td>{d}{s}{s}</td></tr>\n", .{ argc, names[1], argv[1] }) catch |err| {
        std.debug.print("Error: {?}\n", .{err});
        return sqlite.SQLITE_ERROR;
    };

    return sqlite.SQLITE_OK;
}

pub fn pr_tasks() []u8 {
    const select_stmt = "SELECT * FROM task;";
    var buf: [128]u8 = [_]u8{0} ** 128;
    var err_msg: [*c]u8 = undefined;
    const result = sqlite.sqlite3_exec(db, select_stmt, pr_task, &buf, &err_msg);
    if (result != sqlite.SQLITE_OK) {
        std.debug.print("Error getting tasks: {s}\n", .{sqlite.sqlite3_errmsg(db)});
    }
    return &buf;
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
