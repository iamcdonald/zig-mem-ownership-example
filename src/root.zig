const std = @import("std");

pub const NSO = @import("no-self-ownership.zig");
pub const WSO = @import("with-self-ownership.zig");

test {
    _ = NSO;
    _ = WSO;
    std.testing.refAllDecls(@This());
}
