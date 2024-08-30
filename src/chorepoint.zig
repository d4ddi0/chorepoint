const std = @import("std");
const sqlite = @cImport(@cInclude("sqlite3.h"));
const web = @import("chorepoint_web.zig");

// database struct
var db: ?*sqlite.sqlite3 = null;

pub fn main() !void {
    std.debug.print("Hello whorl!", .{});
    try initData();
    defer shutdownData();
    web.init();
    defer web.deinit();
    try web.start();
}

fn initData() !void {
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
    ;
    var err_msg: ?*u8 = null;
    result = sqlite.sqlite3_exec(db, create_stmt, null, null, &err_msg);
    if (result != sqlite.SQLITE_OK) {
        std.debug.print("Error creating task table: {?}\n", .{err_msg});
    }
}

fn shutdownData() void {
    const result = sqlite.sqlite3_close(db);
    if (result != sqlite.SQLITE_OK) {
        std.debug.print("aargh on close!\n", .{});
    }
}
