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
    const Command = enum(u8) { se = 240, nop = 241, data_mark = 242, brk = 243, interrupt_process = 244, abort_output = 245, are_you_there = 246, erase_character = 247, erase_line = 248, go_ahead = 249, sb = 250, will = 251, wont = 252, do = 253, dont = 254, iac = 255, _ };

    const State = enum(u8) {
        idle,
        unexpected_input,
        eat_command,
        eat_parameter,
        eat_subnegotiation_parameter,
        subnegotiating,
        eat_subnegotiation_end,
    };

    state: State,

    pub fn init() TelnetSession {
        return TelnetSession{ .state = .idle };
    }

    pub fn decode(self: *TelnetSession, data: []u8) !usize {
        var write_cursor: usize = 0;

        for (data) |byte| {
            switch (self.state) {
                .idle => {
                    switch (@intToEnum(Command, byte)) {
                        .iac => {
                            self.state = .eat_command;
                        },
                        else => {
                            data[write_cursor] = byte;
                            write_cursor += 1;
                            self.state = .idle;
                        },
                    }
                },
                .unexpected_input => {},
                .eat_command => {
                    switch (@intToEnum(Command, byte)) {
                        .nop, .data_mark, .brk, .interrupt_process, .abort_output, .are_you_there, .erase_character, .erase_line, .go_ahead  => {
                            self.state = .idle;
                        },
                        .sb => { self.state = .eat_subnegotiation_parameter; },
                        .iac, .se => {
                            self.state = .unexpected_input;
                        },
                        .will, .wont, .do, .dont => {
                            self.state = .eat_parameter;
                        },
                        else => {
                            self.state = .idle;
                        },
                    }
                },
                .eat_parameter => {
                    self.state = .idle;
                },
                .eat_subnegotiation_parameter => {
                    self.state = .subnegotiating;
                },
                .subnegotiating => {
                    switch (@intToEnum(Command, byte)) {
                        .iac => {
                            self.state = .eat_subnegotiation_end;
                        },
                        else => {
                            self.state = .subnegotiating;
                        }
                    }
                },
                .eat_subnegotiation_end => {
                    switch (@intToEnum(Command, byte)) {
                        .se => {
                            self.state = .idle;
                        },
                        else => {
                            self.state = .unexpected_input;
                        }
                    }
                }
            }
        }

        return write_cursor;
    }
};

fn processClient(connection: net.StreamServer.Connection) !void {
    defer connection.stream.close();

    print("Cilent connected from {}\n", .{connection.address});

    var telnet_session = TelnetSession.init();

    while (true) {
        var buffer: [64]u8 = undefined;
        const bytes_read = try connection.stream.read(&buffer);

        if (bytes_read == 0) {
            print("Client disconnected from {}\n", .{connection.address});
            break;
        }
        const bytes_decoded = try telnet_session.decode(buffer[0..bytes_read]);
        if (bytes_decoded > 0) {
            print("{s}", .{buffer[0..bytes_decoded]});
        }
    }

}

pub fn main() anyerror!void {
    const options = net.StreamServer.Options{ .kernel_backlog = 0, .reuse_address = true };
    var server = net.StreamServer.init(options);
    defer server.deinit();

    const listen_address = net.Address.parseIp4("0.0.0.0", 23) catch unreachable;
    try server.listen(listen_address);
    print("Listening on {}\n", .{listen_address});

    while (true) {
        if (server.accept()) |connection| {
            _ = async processClient(connection);
            
            
        } else |err| {
            print("Error: {}\n", .{err});
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
