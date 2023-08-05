#pragma once

#include "board.hpp"

enum Piece {
    King,
    Queen,
    Rook,
    Bishop,
    Knight,
    Pawn    
};

#define isNonSlidingBoard(x) ((x) == white_king   || (x) == black_king   || \
                             (x) == white_knight || (x) == black_knight || \
                             (x) == white_pawn   || (x) == black_pawn)
