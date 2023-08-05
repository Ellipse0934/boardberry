#include "board.hpp"

#include <iostream>
#include <unordered_map>

#define CTPI(x) (CHAR_TO_PIECE[(x)])

Board::Board(std::string x) {
    // I know, I know, I can just use an array and it will be faster and stuff,
    // but it's just a one time cost, so I don't really care.

    std::unordered_map<char, int> CHAR_TO_PIECE = {
        {'K', white_king},
        {'k', black_king},
        {'Q', white_queen},
        {'q', black_queen},
        {'R', white_rook},
        {'r', black_rook},
        {'B', white_bishop},
        {'b', black_bishop},
        {'N', white_knight},
        {'n', black_knight},
        {'P', white_pawn},
        {'p', black_pawn},
    };

    u8 rank = 7;
    u8 file = 0;

    for (size_t i = 0; i < x.length(); i++) {
        char c = x[i];

        if (c == '/') {
            rank--; file = 0;
            continue;
        }

        if (isdigit(c)) {
            u8 as_number = c - '1';
            
            file += as_number;
        }

        if (c == ' ') {
            i++;
            side = x[i++] == 'w' ? white : black;

            i++;
            
            while (x[i] != ' ') {
                if (x[i] == '-')
                    break;
                
                if (x[i] == 'K') white_castle_king  = true;
                if (x[i] == 'k') black_castle_king  = true;
                if (x[i] == 'Q') white_castle_queen = true;
                if (x[i] == 'q') black_castle_queen = true;

                i++;
            }

            i++;

            if (x[i] != '-') en_passant_square = (x[i+1] - '1') * 8 + (x[i] - 'a');
            else {en_passant_square = -1;}
            
            break;
        }

        if (isupper(c) || islower(c)) {
            u64 square = 1ULL << (rank * 8 + file);

            pieces[CHAR_TO_PIECE[c]] |= square;
            pieces[white_pieces + islower(c)] |= square;
            pieces[all_pieces] |= square;
        }

        file++;
    }

    this->generateAttacks();
}
