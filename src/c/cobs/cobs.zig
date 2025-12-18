const std = @import("std");
const cobsr = @cImport({
    @cInclude("cobs/cobsr.h");
});

fn cobs_example() !void {
    // 原始数据 - 字符串消息
    const original_data: [12]u8 = [_]u8{ 'H', 'e', 'l', 'l', 'o', ' ', 'W', 'o', 'r', 'l', 'd', '!' };

    // 计算编码后所需的最大缓冲区大小
    const encoded_max_len = cobsr.COBSR_ENCODE_DST_BUF_LEN_MAX(original_data.len);
    var encoded_data: [20]u8 = undefined; // 使用足够大的缓冲区

    // 编码过程
    const encode_result = cobsr.cobsr_encode(&encoded_data, encoded_max_len, &original_data, original_data.len);

    if (encode_result.status != cobsr.COBSR_ENCODE_OK) {
        std.debug.print("Encoding failed with status: {}\n", .{encode_result.status});
        return error.EncodingFailed;
    }

    std.debug.print("Encoded {} bytes into {} bytes\n", .{ original_data.len, encode_result.out_len });

    // 打印编码前的字符串
    std.debug.print("Original message: {s}\n", .{original_data});

    // 打印编码后的数据（十六进制格式）
    std.debug.print("Encoded data (hex): ", .{});
    for (encoded_data[0..encode_result.out_len]) |byte| {
        std.debug.print("{X:0>2} ", .{byte});
    }
    std.debug.print("\n", .{});

    // 解码过程
    const decoded_max_len = cobsr.COBSR_DECODE_DST_BUF_LEN_MAX(encode_result.out_len);
    var decoded_data: [20]u8 = undefined; // 使用足够大的缓冲区

    const decode_result = cobsr.cobsr_decode(&decoded_data, decoded_max_len, &encoded_data, encode_result.out_len);

    if (decode_result.status != cobsr.COBSR_DECODE_OK) {
        std.debug.print("Decoding failed with status: {}\n", .{decode_result.status});
        return error.DecodingFailed;
    }

    std.debug.print("Decoded back to {} bytes\n", .{decode_result.out_len});

    // 打印解码后的字符串
    std.debug.print("Decoded message: {s}\n", .{decoded_data[0..decode_result.out_len]});

    // 验证数据一致性
    if (decode_result.out_len == original_data.len and
        std.mem.eql(u8, original_data[0..], decoded_data[0..decode_result.out_len]))
    {
        std.debug.print("Success: Original and decoded data match!\n", .{});
    } else {
        std.debug.print("Error: Data mismatch after decode\n", .{});
        return error.DataMismatch;
    }
}
