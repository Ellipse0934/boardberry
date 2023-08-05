#include <boardberry/board.hpp>
#include <string>
#include <cassert>
#include <iostream>

int main() {
    Board board_fen_starting  = Board(STARTING_FEN);
    Board board_hand_starting = Board();

    BitBoard pieces_hand_array[] = {
        16ULL, 1152921504606846976ULL, 8ULL, 576460752303423488ULL, 129, 
        9295429630892703744ULL, 36ULL, 2594073385365405696ULL, 66, 
        4755801206503243776ULL, 65280ULL, 71776119061217280ULL, 65535, 
        18446462598732840960ULL, 18446462598732906495ULL
    };

    for (int i = 0; i < 15; i++) board_hand_starting.pieces[i] = pieces_hand_array[i];
    
    for (int i = 0; i < 15; i++)
        assert(board_fen_starting.pieces[i] == board_hand_starting.pieces[i]);

    Board board_fen_empty  = Board(EMPTY_FEN);
    Board board_hand_empty = Board();

    assert(board_fen_empty == board_hand_empty);

    return 0;
}
