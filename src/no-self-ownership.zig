const std = @import("std");

const Child = struct {
    list: std.ArrayList(u16),
    secret: []const u8,
    pub fn init(allocator: std.mem.Allocator, secret: []const u8) Child {
        return .{ .list = std.ArrayList(u16).init(allocator), .secret = secret };
    }
    pub fn deinit(self: Child) void {
        self.list.deinit();
    }
};

const Parent = struct {
    child: Child,
    pub fn init(allocator: std.mem.Allocator) Parent {
        return .{
            .child = Child.init(allocator, "shhhhhh!!!"),
        };
    }

    pub fn deinit(self: Parent) void {
        self.child.deinit();
    }
};

test "Parent/Child - no self ownership" {
    // p_stack exists on the stack here - will dissappear after the function finishes
    var p_stack = Parent.init(std.testing.allocator);
    // We still need to deinit to free the underlying data allocated by the std.ArrayList
    defer p_stack.deinit();
    try p_stack.child.list.append(12);
    try std.testing.expectEqualSlices(u16, p_stack.child.list.items, &.{12});

    // We allocate enough memory to hole an istance of the Parent struct
    const p_in_memory = try std.testing.allocator.create(Parent);
    // As we have this struct now in memory we need to free both the memory and deinit the instance
    // THIS PART FEELS A BIT WEIRD
    defer std.testing.allocator.destroy(p_in_memory);
    defer p_in_memory.deinit();
    // Then assign a Parent struct instance to that memory
    p_in_memory.* = Parent.init(std.testing.allocator);
    try p_in_memory.child.list.append(900);
    try std.testing.expectEqualSlices(u16, p_in_memory.child.list.items, &.{900});
}
