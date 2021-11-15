const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;

fn sort(array: []u8) void {
    for (array) |_, i| {
        var j: usize = i + 1;
        while (j < array.len) : (j += 1) {
            if (array[j] < array[i]) {
                const temp = array[i];
                array[i] = array[j];
                array[j] = temp;
            }
        }
    }
}

test "sort" {
    var array = [_]u8{ 5, 6, 7, 1, 3, 0, 9, 7 };
    sort(&array);

    for (array) |value, i| {
        if (i == 0) {
            continue;
        }

        try expect(value >= array[i - 1]);
    }
}


fn Heap(comptime T: type, key: fn(T) usize) type {
    return struct {
        const Self = @This();

        size: usize,
        heap: []T,
        allocator: *std.mem.Allocator,

        pub fn init(allocator: *std.mem.Allocator) !Self {
            const heap = try allocator.alloc(T, 1);
            return Self{
                .size = 0,
                .heap = heap,
                .allocator = allocator,
            };
        }
        
        pub fn deinit(self: Self) void {
            self.allocator.free(self.heap);
        }

        fn maybeGrow(self: *Self) !void {
            if (self.size == self.heap.len) {
                self.heap = try self.allocator.realloc(self.heap, self.heap.len * 2);
            }
        }

        fn parent(index: usize) ?usize {
            if (index == 0) {
                return null;
            }

            return (index - 1) / 2;
        }

        fn equal(a : ?usize, b : ?usize) bool {
            if (a == null and b == null) {
                return true;
            } else if (a == null or b == null) {
                return false;
            } else {
                return a.? == b.?;
            }
        }

        test "parent index" {
            const Test = struct { index : usize, parent : ?usize };
            const results = [_]Test{
                Test{ .index = 0, .parent = null },
                Test{ .index = 1, .parent = 0 },
                Test{ .index = 2, .parent = 0 },
                Test{ .index = 3, .parent = 1 },
                Test{ .index = 4, .parent = 1 },
                Test{ .index = 5, .parent = 2 },
                Test{ .index = 6, .parent = 2 },
            };

            for (results) |test_case| {
                const p = parent(test_case.index);
                try expect(equal(parent(test_case.index), test_case.parent));
            }
        }

        pub fn insert(self: *Self, value: T) !void {
            try maybeGrow(self);
            var index : ?usize = self.size; 
            self.heap[index.?] = value;

            while (index) |index_value| {
                const p = parent(index_value);
                if (p) |parent_index| {
                    if (self.heap[parent_index] <= self.heap[index_value]) {
                        break;
                    }

                    const temp = self.heap[parent_index];
                    self.heap[parent_index] = self.heap[index_value];
                    self.heap[index_value] = temp;
                }

                index = p;
            }

            self.size += 1;
        }

        pub fn extractMin(self: Self) ?T {
            return null;
        }
    };
}

fn mykey(x: usize) usize {
    return x;
}

test "heap" {
    var heap = try Heap(usize, mykey).init(std.heap.page_allocator);
    defer heap.deinit();
    try heap.insert(4000);
    try heap.insert(3000);
    try heap.insert(2000);
    try heap.insert(1000);
    try std.io.getStdOut().writer().print("size {any}\n", .{ heap.heap });
}