const std = @import("std");

const console_module = @import("console.zig");
const Console = console_module.Console;
const Vec2 = console_module.Vec2;
const input_module = @import("input.zig");
const Input = input_module.Input;
const Action = input_module.Action;

const World = struct {
    player_position: Vec2,

    pub fn init() World {
        return World{
            .player_position = Vec2{ .x = 0, .y = 0 },
        };
    }
};

const net = std.net;
const print = std.debug.print;

const TelnetSession = struct {
    const Command = enum(u8) {
        SE = 240,
        NOP = 241,
        DataMark = 242,
        Break = 243,
        InterruptProcess = 244,
        AbortOutput = 245,
        AreYouThere = 246,
        EraseCharacter = 247,
        EraseLine = 248,
        GoAhead = 249,
        SB = 250,
        WILL = 251,
        WONT = 252,
        DO = 253,
        DONT = 254,
        IAC = 255,
        _
    };

    pub fn decode(data: []u8) void {
        for (data) |command_byte| {
            const command = @intToEnum(Command, command_byte);
            print("{} ", .{ command });
        }
    }
};

pub fn main() anyerror!void {
    const options = net.StreamServer.Options{
        .kernel_backlog = 0,
        .reuse_address = true
    };
    var server = net.StreamServer.init(options);
    defer server.deinit();

    const listen_address = net.Address.parseIp4("0.0.0.0", 23) catch unreachable;
    try server.listen(listen_address);
    print("Listening on {}\n", .{ listen_address });

    while (true) {
        if (server.accept()) |connection| {
            defer connection.stream.close();

            print("Cilent connected from {}\n", .{ connection.address });
            var buffer: [64]u8 = undefined;
            const bytes_read = try connection.stream.read(&buffer);
            
            print("Read {} bytes:\n", .{ bytes_read });
            TelnetSession.decode(buffer[0..bytes_read]);
            print("\n", .{});

            _ = try connection.stream.write("Hello, world!");
        } else |err| {
            print("Error: {}\n", .{ err });
        }

    }

}
//pub fn main() anyerror!void {
//    const console = try Console.init();
//    defer console.deinit();
//
//    const input = try Input.init();
//
//    console.setCursorVisible(false);
//    console.clear();
//    console.goto(10, 10);
//    console.setColor();
//    const message: []const u8 = "Welcome traveler, it's been a long time since you've been concious!\n";
//    console.write(message);
//    console.clearColor();
//
//    const size = console.size();
//    console.goto(0, 0);
//    console.write("X");
//    console.goto(size.x - 1, size.y - 1);
//    console.write("X");
//    console.goto(0, size.y - 1);
//    console.write("X");
//    console.goto(size.x - 1, 0);
//    console.write("X");
//
//    var position = Vec2{ .x = 0, .y = 0 };
//    var old_position = position;
//
//    main: while (true) {
//        console.goto(old_position.x, old_position.y);
//        console.write(" ");
//        console.goto(position.x, position.y);
//        console.write("@");
//
//        old_position = position;
//
//        switch (input.readAction()) {
//            .exit => break :main,
//            .left => {
//                position.x -= 1;
//            },
//            .right => {
//                position.x += 1;
//            },
//            .up => {
//                position.y -= 1;
//            },
//            .down => {
//                position.y += 1;
//
//            },
//        }
//    }
//
//    console.clear();
//}
