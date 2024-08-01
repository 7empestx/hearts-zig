const std = @import("std");
const print = std.debug.print;
const RndGen = std.rand.DefaultPrng;

const cards_in_deck: u8 = 52;

const Card = struct { suit: []const u8, rank: []const u8 };
const Deck = struct { cards: [cards_in_deck]Card };

pub fn main() !void {
    // Create a base deck of cards
    const deck = generateDeck();

    const gameDeck = shuffleDeck(deck);
    printDeck(gameDeck);

    // Randomize deck of cards to new deck
    // Assign the first 13 cards to the first player and so on
}

fn printDeck(deck: Deck) void {
    for (deck.cards) |c| {
        print("{s} {s}\n", .{ c.rank, c.suit });
    }
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
