const std = @import("std");
const sqlite = @cImport(@cInclude("sqlite3.h"));

// database struct
var db: ?*sqlite.sqlite3 = null;

pub const Task = struct {
    id: u32,
    name: []u8,
    description: []u8,
    individual: bool,
    warn_period_sec: u32,
    alert_period_sec: u32,
    points_value: u32,
    txt: [256]u8 = undefined,
};

fn parseIntZ(str: [*c]const u8) u32 {
    var result: u32 = 0;
    var i: usize = 0;
    if (str == null) {
        return 0;
    }
    while (str[i] != 0) {
        if ((str[i] < '0') or (str[i] > '9')) {
            // Is it wrong to just ignore invalid inputs???
            continue;
        }
        result = (result * 10) + (str[i] - '0');
        i += 1;
    }
    return result;
}

test "parseIntZ" {
    try std.testing.expectEqual(5, parseIntZ("05"));
    try std.testing.expectEqual(0, parseIntZ("Joshua"));
    try std.testing.expectEqual(0, parseIntZ(null));
    try std.testing.expectEqual(410, parseIntZ("d4dd10"));
    try std.testing.expectEqual(1000, parseIntZ("-1000")); // not handling negative
    //TODO: test for overflow
}

export fn getTask(data: ?*anyopaque, _: c_int, argv: [*c][*c]const u8, _: [*c][*c]u8) i32 {
    if (data == null) {
        return sqlite.SQLITE_ERROR;
    }
    const tasks: *[]Task = @alignCast(@ptrCast(data));
    tasks.*.len += 1;
    const task = &(tasks.*[tasks.*.len - 1]);
    task.*.id = parseIntZ(argv[0]);
    task.*.name = std.fmt.bufPrint(task.*.txt[0..], "{s}", .{argv[1]}) catch {
        task.*.name = "";
        return sqlite.SQLITE_ERROR;
    };
    task.*.description = std.fmt.bufPrint(task.*.txt[task.*.name.len..], "{s}", .{argv[2]}) catch {
        task.*.description = "";
        return sqlite.SQLITE_ERROR;
    };
    task.*.individual = (parseIntZ(argv[3]) != 0);
    task.*.warn_period_sec = parseIntZ(argv[4]);
    task.*.alert_period_sec = parseIntZ(argv[5]);
    task.*.points_value = parseIntZ(argv[6]);

    return sqlite.SQLITE_OK;
}

pub fn getTasks(available_tasks: []Task) ![]Task {
    //TODO: dynamic offset, maybe also dynamic limit
    var tasks: []Task = available_tasks[0..0];
    const select_stmt = "SELECT * FROM task LIMIT 4 OFFSET 0;";
    var err_msg: [*c]u8 = undefined;
    const result = sqlite.sqlite3_exec(db, select_stmt, getTask, @ptrCast(&tasks), &err_msg);
    defer sqlite.sqlite3_free(err_msg);
    if (result != sqlite.SQLITE_OK) {
        std.debug.print("Error getting tasks: {s}\n", .{err_msg});
        return error.sqliteError;
    }
    return tasks;
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
        \\id INTEGER PRIMARY KEY
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
