const std = @import("std");

const Console = @import("console.zig").Console;
const Vec2 = @import("console.zig").Vec2;
const Input = @import("input.zig").Input;
const Action = @import("input.zig").Action;

pub fn main() anyerror!void {
    const console = try Console.init();
    defer console.deinit();

    const input = try Input.init();

    console.clear();
    console.goto(10, 10);
    console.setColor();
    const message: []const u8 = "Welcome traveler, it's been a long time since you've been concious!\n";
    console.write(message);
    console.clearColor();

    const size = console.size();
    console.goto(0, 0);
    console.write("X");
    console.goto(size.x - 1, size.y - 1);
    console.write("X");
    console.goto(0, size.y - 1);
    console.write("X");
    console.goto(size.x - 1, 0);
    console.write("X");

    var position = Vec2{ .x = 0, .y = 0 };
    var old_position = position;

    main: while (true) {
        console.goto(old_position.x, old_position.y);
        console.write(" ");
        console.goto(position.x, position.y);
        console.write("@");

        old_position = position;

        switch (input.readAction()) {
            .exit => break :main,
            .left => {
                position.x -= 1;
            },
            .right => {
                position.x += 1;
            },
            .up => {
                position.y -= 1;
            },
            .down => {
                position.y += 1;

            },
        }
    }

    console.clear();
}
