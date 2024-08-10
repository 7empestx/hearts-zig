const std = @import("std");
const print = std.debug.print;
const RndGen = std.rand.DefaultPrng;
const spoon_menu = @import("spoon_menu.zig");

const cards_in_deck: u8 = 52;
const player_count: u8 = 4;
const cards_per_player: u8 = cards_in_deck / player_count;

const Card = struct { suit: []const u8, rank: []const u8 };
const Deck = struct { cards: [cards_in_deck]Card };
const Player = struct { player_cards: [cards_per_player]Card };
const Game = struct { players: [player_count]Player };
const Passing = enum { Right, Left, Across };

pub fn main() !void {
    //try spoon_menu.spoonInit();

    // Create a base deck of cards
    const deck = generateDeck();

    // Randomize deck of cards to new deck
    const gameDeck = shuffleDeck(deck);

    // Assign the first 13 cards to the first player and so on
    const players = dealCardsToPlayers(gameDeck);
    printPlayer(players[0]);

    // Create game
    const game = Game{ .players = players };
    _ = game;

    try readPlayerCardSelection();
}

fn readPlayerCardSelection() !void {
    const firstCard = try userInput("first");
    const secondCard = try userInput("second");
    const thirdCard = try userInput("third");
    passCards(firstCard, secondCard, thirdCard);
}

fn passCards(firstCard: u64, secondCard: u64, thirdCard: u64) void {
    // Implement the logic for passing cards here
    std.debug.print("Passing cards: {d}, {d}, {d}\n", .{ firstCard, secondCard, thirdCard });
}

fn userInput(cardString: []const u8) !u64 {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();
    try stdout.print("Select the {s} card to pass to the right: ", .{cardString});
    var buf: [10]u8 = undefined;
    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
        return std.fmt.parseInt(u64, user_input, 10);
    } else {
        return error.NoInput;
    }
}

fn dealCardsToPlayers(gameDeck: Deck) [4]Player {
    const player1Cards: [cards_per_player]Card = gameDeck.cards[0..13].*;
    const player2Cards: [cards_per_player]Card = gameDeck.cards[13..26].*;
    const player3Cards: [cards_per_player]Card = gameDeck.cards[26..39].*;
    const player4Cards: [cards_per_player]Card = gameDeck.cards[39..52].*;

    // Create players
    const player1 = Player{ .player_cards = player1Cards };
    const player2 = Player{ .player_cards = player2Cards };
    const player3 = Player{ .player_cards = player3Cards };
    const player4 = Player{ .player_cards = player4Cards };

    return [4]Player{ player1, player2, player3, player4 };
}

fn printPlayer(player: Player) void {
    print("Printing Player Cards\n", .{});
    for (player.player_cards, 0..) |c, idx| {
        print("{}: {s} of {s}\n", .{ idx, c.rank, c.suit });
    }
    print("\n", .{});
}

fn printDeck(deck: Deck) void {
    print("Printing Deck\n", .{});
    for (deck.cards) |c| {
        print("{s} of {s}\n", .{ c.rank, c.suit });
    }
    print("\n", .{});
}

fn shuffleDeck(deck: Deck) Deck {
    var s_deck = deck;
    for (s_deck.cards[0..], 0..) |_, idx| {
        const r = generateRandomNumber();
        const temp_card = s_deck.cards[idx];
        s_deck.cards[idx] = s_deck.cards[r];
        s_deck.cards[r] = temp_card;
    }
    return s_deck;
}

fn generateRandomNumber() u8 {
    const rand = std.crypto.random;
    return rand.intRangeAtMost(u8, 0, 51);
}

fn generateDeck() Deck {
    const suits = [4][]const u8{ "Hearts", "Spades", "Clovers", "Diamonds" };
    const ranks = [13][]const u8{ "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King", "Ace" };

    var deck = Deck{ .cards = undefined };
    var card_idx: usize = 0;
    for (suits) |s| {
        for (ranks) |r| {
            deck.cards[card_idx] = Card{ .suit = s, .rank = r };
            card_idx += 1;
        }
    }
    return deck;
}

test "Deal Cards to Players" {
    const deck = generateDeck();
    const gameDeck = shuffleDeck(deck);
    const players = dealCardsToPlayers(gameDeck);
    for (players) |p| {
        printPlayer(p);
    }
}

test "Random Number Generation" {
    const rand = generateRandomNumber();
    try std.testing.expect(rand >= 0);
    try std.testing.expect(rand <= 51);
}

test "Generated Deck matches a deck that has been shuffled and sorted" {
    const baseDeck = generateDeck();
    const shuffledDeck = shuffleDeck(generateDeck());

    // TODO
    try std.testing.expect(baseDeck.cards.len == shuffledDeck.cards.len);
}

test "Deck Generates" {
    const deck = generateDeck();
    try std.testing.expect(deck.cards.len == 52);
}
