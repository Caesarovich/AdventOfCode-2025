const std = @import("std");

const INPUT_FILE = "input.txt";

fn readInputFile(allocator: std.mem.Allocator) ![]u8 {
    return try std.fs.cwd().readFileAlloc(allocator, INPUT_FILE, 100_000);
}

// Part one

// fn rotateDial(dial: u32, rotation: u32, toLeft: bool) u32 {
//     const effectiveRotation: u32 = @mod(rotation, 100);

//     if (!toLeft)
//         return ((dial + effectiveRotation) % 100);

//     if (effectiveRotation > dial)
//         return (100 - (effectiveRotation - dial));

//     return (dial - effectiveRotation);
// }

// Part two

fn rotateDial(dial: *u32, rotation: u32, toLeft: bool) u32 {
    var result: u32 = 0;

    for (0..rotation) |_| {
        if (toLeft) {
            if (dial.* == 0) dial.* = 100;
            dial.* = dial.* - 1;
        } else {
            dial.* = dial.* + 1;
            if (dial.* == 100) dial.* = 0;
        }
        if (dial.* == 0) result += 1;
    }

    return (result);
}

fn solvePuzzle(lines: *std.mem.SplitIterator(u8, .scalar)) !u32 {
    var result: u32 = 0;
    var dialPosition: u32 = 50;

    while (lines.next()) |line| {
        if (line.len < 2) continue;
        const num = try std.fmt.parseUnsigned(u32, line[1..], 10);

        result += rotateDial(&dialPosition, num, line[0] == 'L');
    }

    return result;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const fileContent = try readInputFile(allocator);
    defer allocator.free(fileContent);

    var lines = std.mem.splitScalar(u8, fileContent, '\n');
    const result = try solvePuzzle(&lines);

    const writeBuffer = try allocator.alloc(u8, 50);
    defer allocator.free(writeBuffer);

    var out = std.fs.File.stdout().writer(writeBuffer).interface;

    try out.print("The password is: {}", .{result});

    try out.flush();
}
