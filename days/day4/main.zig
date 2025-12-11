const std = @import("std");

const INPUT_FILE = "input.txt";

const NOTE_SIZE = 138;
const PAPER_ROLL = '@';

fn readInputFile(allocator: std.mem.Allocator) ![]const u8 {
    const fileContent = try std.fs.cwd().readFileAlloc(allocator, INPUT_FILE, 100_000);

    return std.mem.trim(u8, fileContent, "\n ");
}

fn parseFileContent(allocator: std.mem.Allocator, fileContent: []const u8) !std.ArrayList([]u8) {
    var lineIterator = std.mem.splitScalar(u8, fileContent, '\n');

    var lines = try std.ArrayList([]u8).initCapacity(allocator, NOTE_SIZE);

    while (lineIterator.next()) |line| {
        lines.appendAssumeCapacity(try allocator.dupe(u8, line));
    }

    return lines;
}

fn countAdjacent(grid: std.ArrayList([]u8), x: usize, y: usize, range: usize) u64 {
    const minX = x -| range;
    const maxX = @as(usize, @min(x + range + 1, grid.items[0].len));

    const minY = y -| range;
    const maxY = @as(usize, @min(y + range + 1, grid.items.len));

    var count: u64 = 0;

    for (minY..maxY) |posY| {
        for (minX..maxX) |posX| {
            if (posX == x and posY == y) continue;
            if (grid.items[posY][posX] != PAPER_ROLL)
                continue;
            count += 1;
        }
    }

    return count;
}

fn removeRolls(rows: std.ArrayList([]u8)) u64 {
    var removed: u64 = 0;

    for (0..rows.items.len) |y| {
        for (0..rows.items[y].len) |x| {
            if (rows.items[y][x] != PAPER_ROLL)
                continue;

            if (countAdjacent(rows, x, y, 1) >= 4)
                continue;

            rows.items[y][x] = '.';
            removed += 1;
        }
    }

    return removed;
}

fn solvePuzzle(rows: std.ArrayList([]u8)) u64 {
    var count = removeRolls(rows);
    var total: u64 = count;

    while (count > 0) {
        count = removeRolls(rows);
        total += count;
    }

    return total;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const fileContent = try readInputFile(allocator);
    defer allocator.free(fileContent);

    var lines = try parseFileContent(allocator, fileContent);
    defer lines.deinit(allocator);

    const result = solvePuzzle(lines);

    const writeBuffer = try allocator.alloc(u8, 50);
    defer allocator.free(writeBuffer);

    var out = std.fs.File.stdout().writer(writeBuffer).interface;

    try out.print("The result is: {}\n", .{result});

    try out.flush();
}
