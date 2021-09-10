usingnamespace @cImport({
    @cInclude("libwebsockets.h");
    @cInclude("string.h");
    @cInclude("signal.h");
    @cDefine("LWS_PLUGIN_STATIC", "");
});
const minimal = @cImport(@cInclude("protocol_lws_minimal.c"));

const std = @import("std");

// pub const struct_lws_protocols = extern struct {
//     name: [*c]const u8,
//     callback: ?lws_callback_function,
//     per_session_data_size: usize,
//     rx_buffer_size: usize,
//     id: c_uint,
//     user: ?*c_void,
//     tx_packet_size: usize,
// };

const protocols: [3]struct_lws_protocols = [3]struct_lws_protocols{
    struct_lws_protocols{
        .name = "http",
        .callback = lws_callback_http_dummy,
        .per_session_data_size = @bitCast(usize, @as(c_long, @as(c_int, 0))),
        .rx_buffer_size = @bitCast(usize, @as(c_long, @as(c_int, 0))),
        .id = 0,
        .user = null,
        .tx_packet_size = 0,
    },
    minimal.LWS_PLUGIN_PROTOCOL_MINIMAL,
    struct_lws_protocols{ // terminator
        .name = null,
        .callback = null,
        .per_session_data_size = @bitCast(usize, @as(c_long, @as(c_int, 0))),
        .rx_buffer_size = @bitCast(usize, @as(c_long, @as(c_int, 0))),
    },
};

const retry: lws_retry_bo_t = lws_retry_bo_t{
    .secs_since_valid_ping = @bitCast(u16, @truncate(c_short, @as(c_int, 3))),
    .secs_since_valid_hangup = @bitCast(u16, @truncate(c_short, @as(c_int, 10))),
};

var interrupted = false;

const mount: struct_lws_http_mount = struct_lws_http_mount{ .def = "index.html" };

pub export fn sigintHandler(arg: c_int) void {
    interrupted = true;
}

pub fn main() anyerror!void {
    var info: lws_context_creation_info = undefined;
    var context: ?*struct_lws_context = undefined;
    // var p: [*c]const u8 = undefined;
    var n: u32 = 0;
    const logs = LLL_USER | LLL_ERR | LLL_WARN | LLL_NOTICE;

    _ = signal(SIGINT, sigintHandler);

    lws_set_log_level(logs, null);
    // lwsl_user("Serving http://localhost:7681\n");

    std.log.info("All your codebase are belong to us.", .{});
}
