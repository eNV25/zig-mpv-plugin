const C = @cImport(@cInclude("mpv/client.h"));
const std = @import("std");
const debug = std.debug;
const mem = std.mem;

export fn mpv_open_cplugin(ctx: *C.mpv_handle) c_int {
    debug.print("Setting up on_load hook.\n", .{});
    _ = C.mpv_hook_add(ctx, 0, "on_load", 11);

    while (true) {
        const ev: *C.mpv_event = C.mpv_wait_event(ctx, -1);
        switch (ev.event_id) {
            C.MPV_EVENT_SHUTDOWN => {
                return 0;
            },
            C.MPV_EVENT_HOOK => {
                const hook: *C.mpv_event_hook = @ptrCast(@alignCast(ev.data));

                if (mem.eql(u8, mem.span(hook.name), "on_load")) {
                    const url = C.mpv_get_property_string(ctx, "stream-open-filename");
                    defer C.mpv_free(url);
                    if (url != null) {
                        debug.print("now playing {s}\n", .{url});
                    }
                }

                _ = C.mpv_hook_continue(ctx, hook.id);
            },
            else => {},
        }
    }
}
