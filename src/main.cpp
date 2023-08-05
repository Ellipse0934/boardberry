#include <boardberry/board.hpp>
#include <boardberry/version.hpp>

#include <iostream>
#include <cstdio>

int main() {
    print_version();

    Board board = Board(STARTING_FEN);

    std::cout << board.pieces[all_pieces] << std::endl;
    std::cout << int(board.en_passant_square) << std::endl;
    std::cout << board.attacks[white_attacks] << " " << board.attacks[black_attacks] << std::endl;
}
