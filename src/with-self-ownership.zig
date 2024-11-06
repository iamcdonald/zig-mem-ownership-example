const std = @import("std");

const Child = struct {
    _allocator: std.mem.Allocator,
    list: std.ArrayList(u16),
    secret: []const u8,
    pub fn init(allocator: std.mem.Allocator, secret: []const u8) !*Child {
        const inst = try allocator.create(Child);
        inst._allocator = allocator;
        inst.secret = secret;
        inst.list = std.ArrayList(u16).init(allocator);
        return inst;
    }
    pub fn deinit(self: *const Child) void {
        self.list.deinit();
        self._allocator.destroy(self);
    }
};

const Parent = struct {
    _allocator: std.mem.Allocator,
    child: *Child,
    pub fn init(allocator: std.mem.Allocator) !*Parent {
        const inst = try allocator.create(Parent);
        inst.child = try Child.init(allocator, "shhhhhh!!!");
        inst._allocator = allocator;
        return inst;
    }

    pub fn deinit(self: *const Parent) void {
        self.child.deinit();
        self._allocator.destroy(self);
    }
};

test "Parent/Child - with self ownership" {
    // init now allocates memory and returns a pointer to the created instance
    // essentially this means any instance is going to live in memory - never just on the stack
    var p_in_memory = try Parent.init(std.testing.allocator);
    // because we allocate all the memory and it's owned by the instance we can free any child memory
    // and the memory for the istance itself at the same time in the relative deinit
    defer p_in_memory.deinit();
    // try p_in_memory.child.list.append(12);
    // try std.testing.expectEqualSlices(u16, p_in_memory.child.list.items, &.{12});
}
