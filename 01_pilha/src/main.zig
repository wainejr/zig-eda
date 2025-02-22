const std = @import("std");

const Elem = struct {
    content: i32,
    next: ?*Elem,
};

const Stack = struct {
    const Self = @This();
    head: ?*Elem,

    pub fn push(self: *Self, elem: *Elem) void {
        if (self.head == null) {
            self.head = elem;
            return;
        }

        elem.next = self.head;
        self.head = elem;
    }

    pub fn pop(self: *Self) ?*Elem {
        if (self.head == null) {
            return null;
        }
        const elem = self.head.?;
        self.head = elem.next;
        elem.next = null;

        return elem;
    }
};

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

test "test stack" {
    var elem_list: [10]Elem = undefined;
    var stack = Stack{ .head = null };

    for (0..10) |i| {
        elem_list[i] = Elem{ .content = @intCast(i), .next = null };
    }

    // Adicionar todos os elementos a stack e testar se o head é do último inserido
    try std.testing.expect(stack.head == null);
    for (0..10) |i| {
        stack.push(&elem_list[i]);
        try std.testing.expect(stack.head.?.content == i);
    }

    // Remover todos os elementos a stack e testar se o head é do último removido
    for (0..10) |i| {
        const elem_pop = elem_list.len - 1 - i;
        try std.testing.expect(stack.head.?.content == elem_pop);
        _ = stack.pop();
    }
    try std.testing.expect(stack.head == null);
}
