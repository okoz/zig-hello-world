const std = @import("std");
const windows = std.os.windows;
const windows_extended = @import("windows_extended.zig");

pub const Action = enum { exit, left, right, up, down };

pub const Input = struct {
    input_handle: windows.HANDLE,

    pub fn init() !Input {
        const input_handle = try windows.GetStdHandle(windows.STD_INPUT_HANDLE);
        return Input{
            .input_handle = input_handle,
        };
    }

    pub fn wait(self: Input) void {
        outer: while (true) {
            var buffer: [10]windows_extended.INPUT_RECORD = undefined;
            var records_read: windows.DWORD = undefined;
            var buffer_slice = buffer[0..buffer.len];
            _ = windows_extended.ReadConsoleInputA(self.input_handle, buffer_slice, buffer.len, &records_read);
            for (buffer[0..records_read]) |input_record| {
                if (input_record.EventType == windows_extended.KEY_EVENT) {
                    const key_event = input_record.DUMMYUNIONNAME.KeyEvent;
                    if (key_event.bKeyDown != 0 and key_event.wVirtualKeyCode == 0x0d) {
                        break :outer;
                    }
                }
            }
        }
        windows.WaitForSingleObject(self.input_handle, windows.INFINITE) catch unreachable;
    }

    pub fn readAction(self: Input) Action {
        while (true) {
            var buffer: [10]windows_extended.INPUT_RECORD = undefined;
            var records_read: windows.DWORD = undefined;
            var buffer_slice = buffer[0..buffer.len];
            _ = windows_extended.ReadConsoleInputA(self.input_handle, buffer_slice, buffer.len, &records_read);
            for (buffer[0..records_read]) |input_record| {
                if (input_record.EventType == windows_extended.KEY_EVENT) {
                    const key_event = input_record.DUMMYUNIONNAME.KeyEvent;
                    if (key_event.bKeyDown != 0) {
                        switch (key_event.wVirtualKeyCode) {
                            0x1b => return Action.exit, // ESC
                            0x26 => return Action.up, // Up Arrow
                            0x28 => return Action.down, // Down Arrow
                            0x25 => return Action.left, // Left Arrow
                            0x27 => return Action.right, // Right Arrow
                            else => {},
                        }
                    }
                }
            }
        }

        unreachable;
    }
};