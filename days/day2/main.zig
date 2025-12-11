const std = @import("std");

const INPUT_FILE = "input.txt";

fn readInputFile(allocator: std.mem.Allocator) ![]const u8 {
    const fileContent = try std.fs.cwd().readFileAlloc(allocator, INPUT_FILE, 100_000);

    return std.mem.trim(u8, fileContent, "\n ");
}

fn parseFileContent(allocator: std.mem.Allocator, fileContent: []const u8) !std.ArrayList([2]u64) {
    var rangeLines = std.mem.splitScalar(u8, fileContent, ',');

    var ranges = try std.ArrayList([2]u64).initCapacity(allocator, 32);

    while (rangeLines.next()) |line| {
        var iterator = std.mem.splitScalar(u8, line, '-');
        var values: [2]u64 = .{ 0, 0 };

        values[0] = try std.fmt.parseUnsigned(u64, iterator.next() orelse "0", 10);
        values[1] = try std.fmt.parseUnsigned(u64, iterator.next() orelse "0", 10);

        try ranges.append(allocator, values);
    }

    return ranges;
}

inline fn digitCount(num: usize) usize {
    return std.math.log10_int(num) + 1;
}

// Part one

// fn isSillyId(id: usize) bool {
//     const digits = digitCount(id);

//     if (digits < 2 or digits % 2 == 1) return false;

//     const midpoint = digits / 2;
//     const divisor = std.math.pow(usize, 10, midpoint);
//     const left = id / divisor;
//     const right = id % divisor;

//     return left == right;
// }

// Part 2

fn isSillyId(id: usize) bool {
    const digits = digitCount(id);

    if (digits < 2) return false;

    const midpoint = digits / 2;

    for (1..(midpoint + 1)) |sliceSize| {
        if (digits % sliceSize != 0) continue;

        const partsCount = digits / sliceSize;
        var partsBuffer: [256]usize = undefined;
        var parts = std.ArrayList(usize).initBuffer(&partsBuffer);
        var sillydId = id;

        for (0..partsCount) |_| {
            const divisor = std.math.pow(usize, 10, sliceSize);
            parts.appendAssumeCapacity(sillydId % divisor);
            sillydId /= divisor;
        }

        if (std.mem.allEqual(usize, parts.items, parts.items[0]))
            return true;
    }

    return false;
}

fn solveLine(line: [2]u64) u64 {
    var total: u64 = 0;

    for (line[0]..(line[1] + 1)) |id| {
        if (isSillyId(id)) total += id;
    }

    return total;
}

fn solvePuzzle(lines: *std.ArrayList([2]u64)) u64 {
    var total: u64 = 0;

    for (lines.items) |line| {
        total += solveLine(line);
    }

    return total;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const fileContent = try readInputFile(allocator);
    defer allocator.free(fileContent);

    var ranges = try parseFileContent(allocator, fileContent);
    defer ranges.deinit(allocator);

    const result = solvePuzzle(&ranges);

    const writeBuffer = try allocator.alloc(u8, 50);
    defer allocator.free(writeBuffer);

    var out = std.fs.File.stdout().writer(writeBuffer).interface;

    try out.print("The result is: {}\n", .{result});

    try out.flush();
}
