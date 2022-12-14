# frozen_string_literal: true

require_relative 'piece'

class Bishop < Piece
  def initialize(type, team, square)
    super
    @board_piece = @team == 'team_one' ? 'â' : "\u001b[31mâ"
  end

  def update_valid_moves(all_squares, _other_player)
    @valid_moves = [] # Reset
    lu, ld, ru, rd = add_diagonal_squares(all_squares)

    # Extract from each array only empty squares + first square with an enemy piece;
    # only knights can jump other pieces
    [lu, ld, ru, rd].each { |arr| arr.replace(remove_jumps(arr)) }

    @valid_moves = clean_valid_moves(lu, ld, ru, rd)
  end
end
