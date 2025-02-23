const std = @import("std");

const Elem = struct {
    content: i32,
    next: ?*Elem,
};

const ListSingle = struct {
    const Self = @This();
    head: ?*Elem,

    pub fn insert(self: *Self, elem_ref: ?*Elem, elem_insert: *Elem) void {
        if (elem_ref == null) {
            const prev_head = self.head;
            elem_insert.next = prev_head;
            self.head = elem_insert;
            return;
        }

        const prev_next = elem_ref.?.next;
        elem_ref.?.next = elem_insert;
        elem_insert.next = prev_next;
    }

    pub fn remove(self: *Self, elem: *Elem) void {
        if (elem == self.head) {
            self.head = elem.next;
            elem.next = null;
            return;
        }

        var prev = self.head.?;
        while (prev.next != elem) {
            prev = prev.next.?;
        }
        prev.next = elem.next;
        elem.next = null;
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

fn assert_list(arr_expect: []const i32, list: ListSingle) !void {
    var elem = list.head;
    for (arr_expect) |num| {
        try std.testing.expect(elem.?.content == num);
        elem = elem.?.next;
    }
    try std.testing.expect(elem == null);
}

test "test list" {
    var elem_list: [5]Elem = undefined;
    var list = ListSingle{ .head = null };

    for (0..5) |i| {
        elem_list[i] = Elem{ .content = @intCast(i), .next = null };
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
