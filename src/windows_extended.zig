const std = @import("std");
const windows = std.os.windows;

pub extern "kernel32" fn SetConsoleMode(in_hConsoleHandle: windows.HANDLE, in_dwMode: windows.DWORD) callconv(windows.WINAPI) windows.BOOL;
pub const ENABLE_VIRTUAL_TERMINAL_PROCESSING: windows.DWORD = 0x0004;

pub const KEY_EVENT_RECORD = extern struct {
    bKeyDown: windows.BOOL,
    wRepeatCount: windows.WORD,
    wVirtualKeyCode: windows.WORD,
    wVirtualScanCode: windows.WORD,
    DUMMYUNIONNAME: extern union {
        UnicodeChar: windows.WCHAR,
        AsciiChar: windows.CHAR,
    },
    dwControlKeyState: windows.DWORD,
};

pub const MOUSE_EVENT_RECORD = extern struct {
    dwMousePosition: windows.COORD,
    dwButtonState: windows.DWORD,
    dwControlKeyState: windows.DWORD,
    dwEventFlags: windows.DWORD,
};

pub const WINDOW_BUFFER_SIZE_RECORD = extern struct {
    dwSize: windows.COORD,
};

pub const MENU_EVENT_RECORD = extern struct {
    dwCommandId: windows.UINT,
};
pub const FOCUS_EVENT_RECORD = extern struct {
    bSetFocus: windows.BOOL,
};

pub const FOCUS_EVENT: windows.WORD = 0x0010;
pub const KEY_EVENT: windows.WORD = 0x0001;
pub const MENU_EVENT: windows.WORD = 0x0008;
pub const MOUSE_EVENT: windows.WORD = 0x0002;
pub const WINDOW_BUFFER_SIZE_EVENT: windows.WORD = 0x0004;

pub const INPUT_RECORD = extern struct { EventType: windows.WORD, DUMMYUNIONNAME: extern union {
    KeyEvent: KEY_EVENT_RECORD,
    MouseEvent: MOUSE_EVENT_RECORD,
    WindowBufferSizeEvent: WINDOW_BUFFER_SIZE_RECORD,
    MenuEvent: MENU_EVENT_RECORD,
    FocusEvent: FOCUS_EVENT_RECORD,
} };

pub extern "kernel32" fn ReadConsoleInputA(in_hConsoleInput: windows.HANDLE, out_lpBuffer: [*]INPUT_RECORD, in_nLength: windows.DWORD, out_lpNumberOfEventsRead: *windows.DWORD) callconv(windows.WINAPI) windows.BOOL;

pub const CONSOLE_SCREEN_BUFFER_INFO = extern struct {
    dwSize: windows.COORD,
    dwCursorPosition: windows.COORD,
    wAttributes: windows.WORD,
    srWindow: windows.SMALL_RECT,
    dwMaximumWindowSize: windows.COORD,
};

pub extern "kernel32" fn GetConsoleScreenBufferInfo(in_hConsoleOutput: windows.HANDLE, out_lpConsoleScreenBufferInfo: *CONSOLE_SCREEN_BUFFER_INFO) callconv(windows.WINAPI) windows.BOOL;