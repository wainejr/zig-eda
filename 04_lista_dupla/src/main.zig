const std = @import("std");

const Elem = struct {
    content: i32,
    next: ?*Elem,
    prev: ?*Elem,
};

const ListDouble = struct {
    const Self = @This();
    head: ?*Elem,

    pub fn insert(self: *Self, elem_ref: ?*Elem, elem_insert: *Elem) void {
        if (elem_ref == null) {
            const prev_head = self.head;
            if (self.head != null) {
                self.head.?.prev = elem_insert;
            }
            elem_insert.next = prev_head;
            elem_insert.prev = null;
            self.head = elem_insert;
            return;
        }

        const prev_next = elem_ref.?.next;
        // Update next
        elem_ref.?.next = elem_insert;
        elem_insert.next = prev_next;
        // Update prev
        elem_insert.prev = elem_ref;
        if (prev_next != null) {
            prev_next.?.prev = elem_insert;
        }
    }

    pub fn remove(self: *Self, elem: *Elem) void {
        defer {
            elem.next = null;
            elem.prev = null;
        }

        if (elem == self.head) {
            self.head = elem.next;
            if (self.head != null) {
                self.head.?.prev = null;
            }
            return;
        }

        const prev_elem = elem.prev.?;
        const next_elem = elem.next;

        prev_elem.next = next_elem;
        if (next_elem != null) {
            next_elem.?.prev = prev_elem;
        }
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

fn assert_list(arr_expect: []const i32, list: ListDouble) !void {
    var elem = list.head;

    for (arr_expect, 0..) |num, i| {
        try std.testing.expect(elem != null);
        try std.testing.expect(elem.?.content == num);
        const i_prev: i32 = @as(i32, @intCast(i)) - 1;
        if (i_prev >= 0) {
            const prev = elem.?.prev;
            try std.testing.expect(prev != null);
            try std.testing.expect(prev.?.content == arr_expect[@as(usize, @intCast(i_prev))]);
        }
        elem = elem.?.next;
    }
    try std.testing.expect(elem == null);
}

test "test list doubly" {
    var elem_list: [5]Elem = undefined;
    var list = ListDouble{ .head = null };

    for (0..5) |i| {
        elem_list[i] = Elem{ .content = @intCast(i), .next = null, .prev = null };
    }

    try std.testing.expect(list.head == null);

    // Lista vazia
    list.insert(null, &elem_list[0]);
    try assert_list(&[_]i32{0}, list);
    // 0

    list.insert(null, &elem_list[1]);
    try assert_list(&[_]i32{ 1, 0 }, list);
    // 1 -> 0

    list.insert(&elem_list[0], &elem_list[2]);
    try assert_list(&[_]i32{ 1, 0, 2 }, list);
    // 1 -> 0 -> 2

    list.insert(&elem_list[0], &elem_list[3]);
    try assert_list(&[_]i32{ 1, 0, 3, 2 }, list);
    // 1 -> 0 -> 3 -> 2

    list.insert(&elem_list[1], &elem_list[4]);
    try assert_list(&[_]i32{ 1, 4, 0, 3, 2 }, list);
    // 1 -> 4 -> 0 -> 3 -> 2

    list.remove(&elem_list[1]);
    try assert_list(&[_]i32{ 4, 0, 3, 2 }, list);
    // 4 -> 0 -> 3 -> 2

    list.remove(&elem_list[2]);
    try assert_list(&[_]i32{ 4, 0, 3 }, list);
    // 4 -> 0 -> 3

    list.remove(&elem_list[0]);
    try assert_list(&[_]i32{ 4, 3 }, list);
    // 4 -> 3

    list.remove(&elem_list[4]);
    try assert_list(&[_]i32{3}, list);
    // 3

    list.remove(&elem_list[3]);
    try std.testing.expect(list.head == null);
}
