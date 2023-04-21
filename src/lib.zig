const std = @import("std");
const wchar_t = std.os.windows.WCHAR;
const expect = std.testing.expect;
const expectFmt = std.testing.expectFmt;

pub const Find_Result = extern struct {
    windows_sdk_version: c_int,
    windows_sdk_root: ?*wchar_t,
    windows_sdk_um_library_path: ?*wchar_t,
    windows_sdk_ucrt_library_path: ?*wchar_t,
    vs_exe_path: ?*wchar_t,
    vs_library_path: ?*wchar_t,
};
pub extern fn vswhom_find_visual_studio_and_windows_sdk() Find_Result;
pub extern fn vswhom_free_resources(result: ?*Find_Result) void;

test "Library test" {
    const fr = vswhom_find_visual_studio_and_windows_sdk();
    defer vswhom_free_resources(@constCast(&fr));
    //@constCast - Remove const qualifier from a pointer.

    try expect(fr.windows_sdk_version == 10);
    var path: []const u8 = "C:\\Program Files (x86)\\Windows Kits\\10\\Lib\\10.0.22621.0\\um\\x64";
    try expectFmt(path, "{}", .{std.unicode.fmtUtf16le(std.mem.span(@ptrCast([*:0]u16, fr.windows_sdk_um_library_path)))});
    path = "C:\\Program Files (x86)\\Windows Kits\\10\\Lib\\10.0.22621.0\\ucrt\\x64";
    try expectFmt(path, "{}", .{std.unicode.fmtUtf16le(std.mem.span(@ptrCast([*:0]u16, fr.windows_sdk_ucrt_library_path)))});
    path = "C:\\Program Files (x86)\\Windows Kits\\10\\Lib\\10.0.22621.0";
    try expectFmt(path, "{}", .{std.unicode.fmtUtf16le(std.mem.span(@ptrCast([*:0]u16, fr.windows_sdk_root)))});
    path = "C:\\Program Files\\Microsoft Visual Studio\\2022\\Enterprise\\VC\\Tools\\MSVC\\14.35.32215\\lib\\x64";
    try expectFmt(path, "{}", .{std.unicode.fmtUtf16le(std.mem.span(@ptrCast([*:0]u16, fr.vs_library_path)))});
    path = "C:\\Program Files\\Microsoft Visual Studio\\2022\\Enterprise\\VC\\Tools\\MSVC\\14.35.32215\\bin\\Hostx64\\x64";
    try expectFmt(path, "{}", .{std.unicode.fmtUtf16le(std.mem.span(@ptrCast([*:0]u16, fr.vs_exe_path)))});
}
