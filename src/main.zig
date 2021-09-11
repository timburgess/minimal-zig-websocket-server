const c = @cImport({
    @cInclude("libwebsockets.h");
    @cInclude("string.h");
    @cInclude("signal.h");
    @cInclude("protocol_lws_minimal.c");
    @cDefine("LWS_PLUGIN_STATIC", "");
});

const std = @import("std");

// pub const struct_lws_protocols = extern struct {
//     name: [*]const u8,
//     callback: ?lws.lws_callback_function,
//     per_session_data_size: usize,
//     rx_buffer_size: usize,
//     id: c_uint,
//     user: ?*c_void,
//     tx_packet_size: usize,
// };

pub const protocols: [3]c.struct_lws_protocols = [3]c.struct_lws_protocols{
    c.struct_lws_protocols{
        .name = "http",
        .callback = c.lws_callback_http_dummy,
        .per_session_data_size = @bitCast(usize, @as(c_long, @as(c_int, 0))),
        .rx_buffer_size = @bitCast(usize, @as(c_long, @as(c_int, 0))),
        .id = 0,
        .user = null,
        .tx_packet_size = 0,
    },
    c.struct_lws_protocols{
        .name = "lws-minimal",
        .callback = c.callback_minimal,
        .per_session_data_size = @sizeOf(c.struct_per_session_data__minimal),
        .rx_buffer_size = @bitCast(usize, @as(c_long, @as(c_int, 128))),
        .id = @bitCast(c_uint, @as(c_int, 0)),
        .user = @intToPtr(?*c_void, @as(c_int, 0)),
        .tx_packet_size = @bitCast(usize, @as(c_long, @as(c_int, 0))),
    },
    // LWS_PLUGIN_PROTOCOL_MINIMAL,
    c.struct_lws_protocols{ // terminator
        .name = null,
        .callback = null,
        .per_session_data_size = @bitCast(usize, @as(c_long, @as(c_int, 0))),
        .rx_buffer_size = @bitCast(usize, @as(c_long, @as(c_int, 0))),
        .id = 0,
        .user = null,
        .tx_packet_size = 0,
    },
};

const retry: c.lws_retry_bo_t = c.lws_retry_bo_t{
    .secs_since_valid_ping = @bitCast(u16, @truncate(c_short, @as(c_int, 3))),
    .secs_since_valid_hangup = @bitCast(u16, @truncate(c_short, @as(c_int, 10))),
};

// file serving particulars for lws
// const mount: lws_http_mount = {
// 	/* .mount_next */		NULL,		/* linked-list "next" */
// 	/* .mountpoint */		"/",		/* mountpoint URL */
// 	/* .origin */			"./mount-origin",  /* serve from dir */
// 	/* .def */			"index.html",	/* default filename */
// 	/* .protocol */			NULL,
// 	/* .cgienv */			NULL,
// 	/* .extra_mimetypes */		NULL,
// 	/* .interpret */		NULL,
// 	/* .cgi_timeout */		0,
// 	/* .cache_max_age */		0,
// 	/* .auth_mask */		0,
// 	/* .cache_reusable */		0,
// 	/* .cache_revalidate */		0,
// 	/* .cache_intermediaries */	0,
// 	/* .origin_protocol */		LWSMPRO_FILE,	/* files in a dir */
// 	/* .mountpoint_len */		1,		/* char count */
// 	/* .basic_auth_login_file */	NULL,
// };
// const mount: lws_http_mount = {
// 	null,
// 	"/",
// 	"./mount-origin",
// 	"index.html",
// 	null,
// 	null,
// 	null,
// 	null,
// 	/* .cgi_timeout */		0,
// 	/* .cache_max_age */		0,
// 	/* .auth_mask */		0,
// 	/* .cache_reusable */		0,
// 	/* .cache_revalidate */		0,
// 	/* .cache_intermediaries */	0,
// 	/* .origin_protocol */		LWSMPRO_FILE,	/* files in a dir */
// 	/* .mountpoint_len */		1,		/* char count */
// 	/* .basic_auth_login_file */	NULL,
// };
const mount: c.struct_lws_http_mount = undefined;

var interrupted = false;

pub export fn sigintHandler(_: c_int) void {
    interrupted = true;
}

pub fn main() anyerror!void {
    var info: c.lws_context_creation_info = undefined;
    // var context: ?*lws.struct_lws_context = undefined;
    // var p: [*c]const u8 = undefined;
    // var n: u32 = 0;
    const logs = c.LLL_USER | c.LLL_ERR | c.LLL_WARN | c.LLL_NOTICE;

    _ = c.signal(c.SIGINT, sigintHandler);

    // setup log levels and log first user log
    c.lws_set_log_level(logs, null);
    c._lws_log(c.LLL_USER, "Serving http://localhost:9000\n");

    // init info struct otherwise it's uninitialized garbage
    _ = c.memset(@ptrCast(?*c_void, &info), @as(c_int, 0), @sizeOf(c.struct_lws_context_creation_info));
    info.port = 9000;
    // info.mounts = &mount;
    // info.protocols = &protocols;
    info.protocols = @ptrCast([*]const c.struct_lws_protocols, @alignCast(@alignOf(*c.struct_lws_protocols), &protocols));

    // info.vhost_name = "localhost";
    // info.options = LWS_SERVER_OPTION_HTTP_HEADERS_SECURITY_BEST_PRACTICES_ENFORCE;

    std.log.info("All your codebase are belong to us.", .{});
}
