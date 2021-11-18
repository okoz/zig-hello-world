const std = @import("std");
const windows = std.os.windows;
const math = std.math;
const windows_extended = @import("windows_extended.zig");

pub const Vec2 = struct {
    x: i16,
    y: i16,
};

pub const Console = struct {
    console_handle: windows.HANDLE,
    saved_mode: windows.DWORD,

    pub fn init() !Console {
        const console_handle = try windows.GetStdHandle(windows.STD_OUTPUT_HANDLE);
        const saved_mode = enableVirtualTerminal(console_handle);

        return Console{
            .console_handle = console_handle,
            .saved_mode = saved_mode,
        };
    }

    pub fn size(self: Console) Vec2 {
        var screen_buffer_info: windows_extended.CONSOLE_SCREEN_BUFFER_INFO = undefined;
        _ = windows_extended.GetConsoleScreenBufferInfo(self.console_handle, &screen_buffer_info);
        return Vec2{ .x = screen_buffer_info.dwSize.X, .y = screen_buffer_info.dwSize.Y };
    }

    pub fn deinit(self: Console) void {
        _ = windows_extended.SetConsoleMode(self.console_handle, self.saved_mode);
    }

    pub fn goto(self: Console, x: i16, y: i16) void {
        const new_cursor_position = windows.COORD{ .X = x, .Y = y };
        _ = windows.kernel32.SetConsoleCursorPosition(self.console_handle, new_cursor_position);
    }

    pub fn write(self: Console, message: []const u8) void {
        const len = math.cast(windows.DWORD, message.len) catch math.maxInt(windows.DWORD);
        _ = windows.kernel32.WriteFile(self.console_handle, message.ptr, len, null, null);
    }

    fn enableVirtualTerminal(console_handle: windows.HANDLE) windows.DWORD {
        var mode: windows.DWORD = undefined;
        _ = windows.kernel32.GetConsoleMode(console_handle, &mode);

        const original_mode = mode;
        mode |= windows_extended.ENABLE_VIRTUAL_TERMINAL_PROCESSING;
        _ = windows_extended.SetConsoleMode(console_handle, mode);

        return original_mode;
    }

    //fn multiParameterCommand(self: Console, command: u8, parameters: []u16) void {
    //    try parameters.len <= 16 catch unreachable;
    //    const escape_sequence = "\x1b[";
    //    const command_length = 1;

    //    var counting_writer = std.io.countingWriter(std.io.null_writer);
    //    std.io.

    //}

    fn singleParameterCommand(self: Console, command: u8, parameter: u16) void {
        var buffer: [64]u8 = undefined;
        var fba = std.heap.FixedBufferAllocator.init(&buffer);

        const command_string = std.fmt.allocPrint(
            &fba.allocator,
            "\x1b[{d}{c}",
            .{ parameter, command },
        ) catch unreachable;
        const len = math.cast(windows.DWORD, command_string.len) catch unreachable;
        _ = windows.kernel32.WriteFile(self.console_handle, command_string.ptr, len, null, null);
    }

    pub fn clear(self: Console) void {
        self.singleParameterCommand('J', 2);
        self.singleParameterCommand('J', 3);
    }

    pub fn setColor(self: Console) void {
        self.singleParameterCommand('m', 4);
    }

    pub fn clearColor(self: Console) void {
        self.singleParameterCommand('m', 24);
    }
};