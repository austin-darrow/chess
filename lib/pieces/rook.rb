# frozen_string_literal: true

require_relative 'piece'

class Rook < Piece
  def initialize(type, team, square)
    super
    @board_piece = @team == 'team_one' ? '♖' : "\u001b[31m♜"
  end

  def update_valid_moves(all_squares, _other_player)
    @valid_moves = [] # Reset
    u, d, l, r = add_cardinal_squares(all_squares)

    # Extract from each array only empty squares + first square with an enemy piece;
    # only knights can jump other pieces
    [l, d].each { |arr| arr.replace(remove_jumps(arr, 'negative')) }
    [r, u].each { |arr| arr.replace(remove_jumps(arr, 'positive')) }

    @valid_moves = clean_valid_moves(l, d, r, u)
  end
end
