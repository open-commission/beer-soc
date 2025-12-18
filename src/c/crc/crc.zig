const std = @import("std");

const c = @cImport({
    @cInclude("crc/crc16.h");
});

pub fn print_crc(data: ?[*]const u8, len: usize) void {
    var result: u16 = 0;

    if (data) |d| {
        result = c.crc16(d, len);
    } else {
        result = c.crc16(null, 0);
    }

    std.debug.print("CRC16: {X}\n", .{result});
}
