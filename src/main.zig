const std = @import("std");
const print = std.debug.print;
const RndGen = std.rand.DefaultPrng;

const cards_in_deck: u8 = 52;
const player_count: u8 = 4;
const cards_to_pass: u8 = 3;
const cards_per_player: u8 = cards_in_deck / player_count;
const pass_cards_store: u8 = player_count * cards_to_pass;

const Card = struct { suit: []const u8, rank: []const u8, passed: bool };
const Deck = struct { cards: [cards_in_deck]Card };
const Player = struct { player_cards: [cards_per_player]Card };
const Game = struct { players: [player_count]Player };
const Passing = enum { Right, Left, Across };
const PassCardSelection = struct { firstCard: u64, secondCard: u64, thirdCard: u64 };
const PassCardStore = struct { cards: [pass_cards_store]Card };

pub fn main() !void {
    // Create a base deck of cards
    const deck = generateDeck();

    // Randomize deck of cards to new deck
    const gameDeck = shuffleDeck(deck);

    // Assign the first 13 cards to the first player and so on
    const players = dealCardsToPlayers(gameDeck);
    printPlayer(players[0], "Player 1");

    // Create game
    var game = Game{ .players = players };

    const passCardSelection = try readPlayerCardSelection();

    var passCardStore = PassCardStore{ .cards = undefined };

    const direction = Passing.Right;
    passCards(passCardSelection, &passCardStore, direction, &game);
}

fn passCards(passCardSelection: PassCardSelection, passCardStore: *PassCardStore, direction: Passing, game: *Game) void {
    _ = direction;
    // Player 1 Card Store
    passCardStore.cards[0] = game.players[0].player_cards[passCardSelection.firstCard];
    passCardStore.cards[1] = game.players[0].player_cards[passCardSelection.secondCard];
    passCardStore.cards[2] = game.players[0].player_cards[passCardSelection.thirdCard];
    game.players[0].player_cards[passCardSelection.firstCard].passed = true;
    game.players[0].player_cards[passCardSelection.secondCard].passed = true;
    game.players[0].player_cards[passCardSelection.thirdCard].passed = true;

    // Player 2 Card Store
    var card1 = getRandomPlayerCard();
    var card2 = getRandomPlayerCard();
    var card3 = getRandomPlayerCard();
    passCardStore.cards[3] = game.players[1].player_cards[card1];
    passCardStore.cards[4] = game.players[1].player_cards[card2];
    passCardStore.cards[5] = game.players[1].player_cards[card3];
    game.players[1].player_cards[card1].passed = true;
    game.players[1].player_cards[card2].passed = true;
    game.players[1].player_cards[card3].passed = true;

    // Player 3 Card Store
    card1 = getRandomPlayerCard();
    card2 = getRandomPlayerCard();
    card3 = getRandomPlayerCard();
    passCardStore.cards[6] = game.players[2].player_cards[card1];
    passCardStore.cards[7] = game.players[2].player_cards[card2];
    passCardStore.cards[8] = game.players[2].player_cards[card3];
    game.players[2].player_cards[card1].passed = true;
    game.players[2].player_cards[card2].passed = true;
    game.players[2].player_cards[card3].passed = true;

    // Player 4 Card Store
    card1 = getRandomPlayerCard();
    card2 = getRandomPlayerCard();
    card3 = getRandomPlayerCard();
    passCardStore.cards[9] = game.players[3].player_cards[card1];
    passCardStore.cards[10] = game.players[3].player_cards[card2];
    passCardStore.cards[11] = game.players[3].player_cards[card3];
    game.players[3].player_cards[card1].passed = true;
    game.players[3].player_cards[card2].passed = true;
    game.players[3].player_cards[card3].passed = true;

    // Player 2 pick up cards from card store 0, 1, 2
    var j: u8 = 0;
    for (game.players[1].player_cards, 0..) |p, i| {
        print("{s} of {s} {}\n", .{ p.rank, p.suit, p.passed });
        if (p.passed) {
            print("Player 2 picked up card from store\n", .{});
            game.players[1].player_cards[i] = passCardStore.cards[j];
            j += 1;
        }
    }
}

fn readPlayerCardSelection() !PassCardSelection {
    return .{ .firstCard = try userInput("first"), .secondCard = try userInput("second"), .thirdCard = try userInput("third") };
}

fn getRandomPlayerCard() u8 {
    const min = 0;
    const max = cards_per_player - 1;

    const rand = generateRandomNumber(min, max);
    return rand;
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

fn printPlayer(player: Player, thePlayer: []const u8) void {
    print("Printing Player Cards for {s}\n", .{thePlayer});
    for (player.player_cards, 0..) |c, idx| {
        print("{}: {s} of {s} {}\n", .{ idx, c.rank, c.suit, c.passed });
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
    const min = 0;
    const max = cards_in_deck - 1;

    for (s_deck.cards[0..], 0..) |_, idx| {
        const r = generateRandomNumber(min, max);
        const temp_card = s_deck.cards[idx];
        s_deck.cards[idx] = s_deck.cards[r];
        s_deck.cards[r] = temp_card;
    }
    return s_deck;
}

fn generateRandomNumber(min: u8, max: u8) u8 {
    const rand = std.crypto.random;
    return rand.intRangeAtMost(u8, min, max);
}

fn generateDeck() Deck {
    const suits = [4][]const u8{ "Hearts", "Spades", "Clovers", "Diamonds" };
    const ranks = [13][]const u8{ "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King", "Ace" };

    var deck = Deck{ .cards = undefined };
    var card_idx: usize = 0;
    for (suits) |s| {
        for (ranks) |r| {
            deck.cards[card_idx] = Card{ .suit = s, .rank = r, .passed = false };
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
        printPlayer(p, "Player");
    }
}

test "Random Number Generation" {
    const rand = generateRandomNumber(0, 51);
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
