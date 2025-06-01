const std = @import("std");

const ErrorBin = error{InvalidOperation};

const Node = struct {
    const Self = @This();
    parent: ?*Node,
    left: ?*Node,
    right: ?*Node,

    content: i32,

    pub fn init(content: i32) Self {
        return .{ .parent = null, .left = null, .right = null, .content = content };
    }

    pub fn add_children(self: *Self, left: ?*Node, right: ?*Node) !void {
        // Check if child doesn't have a parent
        if (right != null and right.?.parent != null) {
            return ErrorBin.InvalidOperation;
        }
        if (left != null and left.?.parent != null) {
            return ErrorBin.InvalidOperation;
        }
        if (left == right or self == left or self == right) {
            return ErrorBin.InvalidOperation;
        }
        // Check if node doesn't have a child in that position
        if (@field(self, "left") != null) {
            return ErrorBin.InvalidOperation;
        }
        if (@field(self, "right") != null) {
            return ErrorBin.InvalidOperation;
        }

        // Set child and parent
        @field(self, "left") = left;
        @field(self, "right") = right;
        if (right != null) {
            right.?.parent = self;
        }
        if (left != null) {
            left.?.parent = self;
        }
    }
};

pub fn main() !void {}

fn assert_node(parent: *Node, left: ?*Node, right: ?*Node) !void {
    try std.testing.expect(parent.left == left);
    try std.testing.expect(parent.right == right);
    if (left != null) {
        try std.testing.expect(left.?.parent == parent);
    }
    if (right != null) {
        try std.testing.expect(right.?.parent == parent);
    }
}

test "arv bin build" {
    var nodes: [10]Node = undefined;
    for (0..10) |i| {
        nodes[i] = Node.init(@intCast(i));
    }

    try nodes[0].add_children(&nodes[1], &nodes[2]);
    try assert_node(&nodes[0], &nodes[1], &nodes[2]);

    try nodes[2].add_children(&nodes[3], null);
    try assert_node(&nodes[2], &nodes[3], null);

    try nodes[3].add_children(null, &nodes[4]);
    try assert_node(&nodes[3], null, &nodes[4]);

    try nodes[1].add_children(&nodes[5], &nodes[6]);
    try assert_node(&nodes[1], &nodes[5], &nodes[6]);

    try nodes[5].add_children(&nodes[7], &nodes[8]);
    try assert_node(&nodes[5], &nodes[7], &nodes[8]);

    try nodes[8].add_children(&nodes[9], null);
    try assert_node(&nodes[8], &nodes[9], null);
}

test "arv bin wrong" {
    var nodes: [10]Node = undefined;
    for (0..10) |i| {
        nodes[i] = Node.init(@intCast(i));
    }

    try nodes[0].add_children(&nodes[1], &nodes[2]);
    try assert_node(&nodes[0], &nodes[1], &nodes[2]);

    nodes[0].add_children(&nodes[3], null) catch |e| {
        try std.testing.expect(e == ErrorBin.InvalidOperation);
    };
    try assert_node(&nodes[0], &nodes[1], &nodes[2]);
}
