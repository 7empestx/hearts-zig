const std = @import("std");
const spoon = @import("spoon");
const heap = std.heap;
const math = std.math;
const mem = std.mem;
const os = std.posix.system;
var term: spoon.Term = undefined;

var loop: bool = true;
var cursor: usize = 0;

pub fn spoonInit() !void {
    try term.init(.{});
    defer term.deinit() catch {};
    try std.posix.sigaction(os.SIG.WINCH, &os.Sigaction{
        .handler = .{ .handler = handleSigWinch },
        .mask = os.empty_sigset,
        .flags = 0,
    }, null);
    var fds: [1]os.pollfd = undefined;
    fds[0] = .{
        .fd = term.tty.?,
        .events = os.POLL.IN,
        .revents = undefined,
    };
    try term.uncook(.{});
    try term.fetchSize();
    try term.setWindowTitle("zig-spoon example: menu", .{});
    try render();
    var buf: [16]u8 = undefined;
    while (loop) {
        _ = try std.posix.poll(&fds, -1);
        const read = try term.readInput(&buf);
        var it = spoon.inputParser(buf[0..read]);
        while (it.next()) |in| {
            if (in.eqlDescription("escape") or in.eqlDescription("q")) {
                loop = false;
                break;
            } else if (in.eqlDescription("arrow-down") or in.eqlDescription("C-n") or in.eqlDescription("j")) {
                if (cursor < 3) {
                    cursor += 1;
                    try render();
                }
            } else if (in.eqlDescription("arrow-up") or in.eqlDescription("C-p") or in.eqlDescription("k")) {
                cursor -|= 1;
                try render();
            }
        }
    }
}

fn render() !void {
    var rc = try term.getRenderContext();
    defer rc.done() catch {};
    try rc.clear();
    if (term.width < 6) {
        try rc.setAttribute(.{ .fg = .red, .bold = true });
        try rc.writeAllWrapping("Terminal too small!");
        return;
    }
    try rc.moveCursorTo(0, 0);
    try rc.setAttribute(.{ .fg = .green, .reverse = true });
    var rpw = rc.restrictedPaddingWriter(term.width);
    try rpw.writer().writeAll("  Hearts Card Game");
    try rpw.pad();
    try rc.moveCursorTo(1, 0);
    try rc.setAttribute(.{ .fg = .red, .bold = true });
    rpw = rc.restrictedPaddingWriter(term.width);
    try rpw.writer().writeAll(" Up and Down arrows to select, q to exit.");
    try rpw.finish();
    const entry_width = @min(term.width - 2, 8);
    try menuEntry(&rc, " foo", 3, entry_width);
    try menuEntry(&rc, " bar", 4, entry_width);
    try menuEntry(&rc, " baz", 5, entry_width);
    try menuEntry(&rc, " →µ←", 6, entry_width);
}

fn menuEntry(rc: *spoon.Term.RenderContext, name: []const u8, row: usize, width: usize) !void {
    try rc.moveCursorTo(row, 2);
    try rc.setAttribute(.{ .fg = .blue, .reverse = (cursor == row - 3) });
    var rpw = rc.restrictedPaddingWriter(width - 1);
    defer rpw.pad() catch {};
    try rpw.writer().writeAll(name);
}

fn handleSigWinch(_: c_int) callconv(.C) void {
    term.fetchSize() catch {};
    render() catch {};
}
