const std = @import("std");

const INPUT_FILE = "input.txt";

const BATTERY_COUNT = 12;

fn readInputFile(allocator: std.mem.Allocator) ![]const u8 {
    const fileContent = try std.fs.cwd().readFileAlloc(allocator, INPUT_FILE, 100_000);

    return std.mem.trim(u8, fileContent, "\n ");
}

fn parseFileContent(allocator: std.mem.Allocator, fileContent: []const u8) !std.ArrayList([100]u8) {
    var lineIterator = std.mem.splitScalar(u8, fileContent, '\n');

    var lines = try std.ArrayList([100]u8).initCapacity(allocator, 200);

    while (lineIterator.next()) |line| {
        var values: [100]u8 = undefined;

        for (0..line.len) |i| {
            values[i] = try std.fmt.charToDigit(line[i], 10);
        }

        lines.appendAssumeCapacity(values);
    }

    return lines;
}

fn findBankHighestJoltage(bank: [100]u8) u64 {
    if (bank.len < BATTERY_COUNT) return 0;

    var highestBatteriesPos: [BATTERY_COUNT]usize = undefined;

    for (0..highestBatteriesPos.len) |i| {
        var highestPos: usize = bank.len;

        var ceiling: u8 = 10;
        while (highestPos > (bank.len - (BATTERY_COUNT - i))) {
            var currentHighestPos: usize = if (i == 0) 0 else highestBatteriesPos[i - 1] + 1;

            for (currentHighestPos..bank.len) |j| {
                if (bank[j] >= ceiling) continue;
                if (bank[j] <= bank[currentHighestPos])
                    continue;
                if (std.mem.containsAtLeastScalar(usize, highestBatteriesPos[0..i], 1, j))
                    continue;
                currentHighestPos = j;
            }

            highestPos = currentHighestPos;

            ceiling -= 1;
        }

        highestBatteriesPos[i] = highestPos;
    }

    var joltage: u64 = 0;

    for (highestBatteriesPos) |pos| {
        joltage *= 10;
        joltage += bank[pos];
    }

    return joltage;
}

fn solvePuzzle(banks: std.ArrayList([100]u8)) u64 {
    var total: u64 = 0;

    var i: u8 = 0;
    for (banks.items) |bank| {
        total += findBankHighestJoltage(bank);
        i += 1;
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
