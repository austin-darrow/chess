# frozen_string_literal: true

require_relative 'piece'

class Knight < Piece
  def initialize(type, team, square)
    super
    @board_piece = @team == 'team_one' ? '♘' : "\u001b[31m♞"
  end

  def update_valid_moves(all_squares, _other_player)
    @valid_moves = [] # Reset

    # Select all potential 8 squares a knight could move to unless coordinates are off the board
    transformations = [[2, 1], [2, -1], [-2, 1], [-2, -1], [1, 2], [1, -2], [-1, 2], [-1, -2]]
    valid_coords = []
    transformations.each do |t|
      next unless (C.index(@square.column) + t[0]).between?(0, 7) && (@square.row + t[1]).between?(1, 8)

      valid_coords << [C[C.index(@square.column) + t[0]], (@square.row + t[1])].join
    end

    # Convert array of valid coordinates into Square objects; add each to @valid_moves
    all_squares.each do |other_square|
      next unless valid_coords.any? { |c| c == other_square.coord }

      @valid_moves << other_square
    end

    @valid_moves = clean_valid_moves(@valid_moves)
  end
end
