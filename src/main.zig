const lws = @cImport(@cInclude("libwebsockets.h"));
const str = @cImport(@cInclude("string.h"));
const sig = @cImport(@cInclude("signal.h"));
const minimal = @cImport(@cInclude("protocol_lws_minimal.c"));

const std = @import("std");

pub const struct_lws_protocols = extern struct {
    name: [*c]const u8,
    callback: ?lws.lws_callback_function,
    per_session_data_size: usize,
    rx_buffer_size: usize,
    id: c_uint,
    user: ?*c_void,
    tx_packet_size: usize,
};

pub const protocols: [2]struct_lws_protocols = [2]struct_lws_protocols{
    struct_lws_protocols{
        .name = "http",
        .callback = lws.lws_callback_http_dummy,
        .per_session_data_size = @bitCast(usize, @as(c_long, @as(c_int, 0))),
        .rx_buffer_size = @bitCast(usize, @as(c_long, @as(c_int, 0))),
        .id = 0,
        .user = null,
        .tx_packet_size = 0,
    },
    minimal.LWS_PLUGIN_PROTOCOL_MINIMAL,

};

const retry: lws.lws_retry_bo_t = lws.lws_retry_bo_t{
    .secs_since_valid_ping = @bitCast(u16, @truncate(c_short, @as(c_int, 3))),
    .secs_since_valid_hangup = @bitCast(u16, @truncate(c_short, @as(c_int, 10))),
};




pub fn main() anyerror!void {
    std.log.info("All your codebase are belong to us.", .{});
}
