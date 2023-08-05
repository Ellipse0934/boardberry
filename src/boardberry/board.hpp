#pragma once

#include "utils.hpp"
#include <string>
#include <iostream>

typedef u64 BitBoard;

enum Pieces {
    white_king,
    black_king,
    white_queen,
    black_queen,
    white_rook,
    black_rook,
    white_bishop,
    black_bishop,
    white_knight,
    black_knight,
    white_pawn,
    black_pawn,
    white_pieces,
    black_pieces,
    all_pieces
};

enum Attacks {
    white_attacks,
    black_attacks
};

enum side_ {
    white,
    black
};

class Board {
public:
    BitBoard pieces[15] = {0};
    BitBoard attacks[2] = {0};

    side_ side;
    i8 en_passant_square = -1;

    bool white_castle_king  = false;
    bool white_castle_queen = false;
    bool black_castle_king  = false;
    bool black_castle_queen = false;

    inline bool operator== (const Board& rhs) const {
        bool pieces_eq = true;
        for (int i = 0; i < 15; i++) {
            if (pieces[i] != rhs.pieces[i]) {
                pieces_eq = false; break;
            }
        }

        bool attacks_eq = attacks[0] == rhs.attacks[0] && attacks[1] == rhs.attacks[1];

        return pieces_eq && attacks_eq && (side == rhs.side);
    }

    void generateAttacks();

    Board() = default;
    Board(std::string);
};

#define STARTING_FEN "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
#define EMPTY_FEN "8/8/8/8/8/8/8/8 w - - 0 0"
