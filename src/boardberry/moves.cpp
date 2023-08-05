// TODO(#5): Sliding pieces (magic bitboards)

#include "board.hpp"
#include "tables.hpp"
#include "pieces.hpp"

#include <vector>

typedef BitBoard (*attack_generator_function)(u8);

inline BitBoard generate_attacks_nonsliding(const u8 square, const BitBoard* table) {
    return table[square];
}

inline BitBoard generate_attacks_knight(u8 square) {
    return generate_attacks_nonsliding(square, (BitBoard*) &KNIGHT_ATTACKS);
}

inline BitBoard generate_attacks_king(u8 square) {
    return generate_attacks_nonsliding(square, (BitBoard*) &KING_ATTACKS);
}

inline BitBoard generate_attacks_pawn(u8 square, bool side) {
    return generate_attacks_nonsliding(square, (BitBoard*) (side ? &PAWN_BLACK_ATTACKS : &PAWN_WHITE_ATTACKS));
}

attack_generator_function attack_generator_functions[] = {
    &generate_attacks_king, &generate_attacks_king, NULL, NULL, NULL, NULL, NULL, NULL,
    &generate_attacks_knight, &generate_attacks_knight
};

inline void generate_moves_nonsliding(Board& board, u8 square, attack_generator_function function, std::vector<BitBoard> moves) {
    BitBoard moves_bb = function(square) & board.pieces[board.side ? black_pieces : white_pieces];

    while (moves_bb != 0) {
        int trailing = 1 << __builtin_ctzll(moves_bb);
        moves.push_back(trailing);
        moves_bb ^= trailing;
    }
}

inline void generate_moves_knight(Board& board, u8 square, std::vector<BitBoard> moves) {
    generate_moves_nonsliding(board, square, attack_generator_functions[white_knight], moves);
}

// TODO(#6): Castling
inline void generate_moves_king(Board& board, u8 square, std::vector<BitBoard> moves) {
    generate_moves_nonsliding(board, square, attack_generator_functions[white_king], moves);
}

// TODO: En passant
BitBoard generate_moves_pawn(const Board& board, const u8 square) {
    u64 pawn = (1ULL << square);

    if (!board.side) {
        u64 single_move = pawn                          << 8 & board.pieces[all_pieces];
        u64 double_move = (single_move & RANK_CLEAR[7]) << 8 & board.pieces[all_pieces];

        return single_move | double_move | PAWN_WHITE_ATTACKS[square];
    } else {
        u64 single_move = pawn                          >> 8 & board.pieces[all_pieces];
        u64 double_move = (single_move & RANK_CLEAR[0]) >> 8 & board.pieces[all_pieces];

        return single_move | double_move | PAWN_BLACK_ATTACKS[square];
    }
}

void Board::generateAttacks() {
    for (int i = 0; i <= black_pawn; i++) {
        BitBoard piece = pieces[i];
        
        if (isNonSlidingBoard(i)) {
            while (piece != 0) {
                int trailing_zeros = __builtin_ctzll(piece);
                
                BitBoard moves = ((i == white_pawn || i == black_pawn) 
                    ? generate_attacks_pawn(trailing_zeros, i % 2)
                    : attack_generator_functions[i](trailing_zeros));

                attacks[i % 2 == 0 ? white_attacks : black_attacks] |= moves;
                piece ^= (1ULL << trailing_zeros);
            }
        }
    }
}
