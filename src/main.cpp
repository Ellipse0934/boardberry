#include <boardberry/board.hpp>

#include <iostream>
#include <cstdio>

int main() {
    Board board = Board(STARTING_FEN);

    std::cout << board.pieces[all_pieces] << std::endl;
    std::cout << int(board.en_passant_square) << std::endl;
}