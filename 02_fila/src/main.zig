const std = @import("std");

const Elem = struct {
    content: i32,
    next: ?*Elem,
};

const Queue = struct {
    const Self = @This();
    head: ?*Elem,

    pub fn push(self: *Self, elem: *Elem) void {
        if (elem.next != null) {
            std.debug.panic("Tentando inserir na fila elemento com next != null", .{});
        }

        if (self.head == null) {
            self.head = elem;
            return;
        }

        var last_elem = self.head.?;
        while (last_elem.next != null) {
            last_elem = last_elem.next.?;
        }
        last_elem.next = elem;
    }

    pub fn pop(self: *Self) ?*Elem {
        const elem = self.head;

        if (elem != null) {
            self.head = elem.?.next;
            elem.?.next = null;
        }

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

test "test queue" {
    var elem_list: [10]Elem = undefined;
    var queue = Queue{ .head = null };

    for (0..10) |i| {
        elem_list[i] = Elem{ .content = @intCast(i), .next = null };
    }

    // Checar se o primeiro elemento se mantém constante, e adicionar todos os outros
    try std.testing.expect(queue.head == null);
    for (0..10) |i| {
        queue.push(&elem_list[i]);
        try std.testing.expect(queue.head.?.content == 0);
    }

    // Checar se os elementos são removidos na ordem que entraram
    for (0..10) |i| {
        try std.testing.expect(queue.head.?.content == i);
        const elem = queue.pop();
        try std.testing.expect(elem.?.content == i);
        try std.testing.expect(elem.?.next == null);
    }
    try std.testing.expect(queue.head == null);
}
