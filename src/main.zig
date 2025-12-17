const std = @import("std");
const beer_soc = @import("beer_soc");
const cobs_c = @cImport({
    @cInclude("cobs.h");
});
pub fn main() !void {
    // 准备数据
    const source_data: [10]u8 = [_]u8{ 1, 2, 3, 4, 5, 0, 6, 7, 8, 9 };
    var destination_buffer: [20]u8 = undefined;

    // 正确调用 cobs_encode
    const result = cobs_c.cobs_encode(&destination_buffer, destination_buffer.len, &source_data, source_data.len);

    std.debug.print("Encoding result: {}\n", .{result});
}

test "simple test" {
    const gpa = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
    try list.append(gpa, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "fuzz example" {
    const Context = struct {
        fn testOne(context: @This(), input: []const u8) anyerror!void {
            _ = context;
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(Context{}, Context.testOne, .{});
}
