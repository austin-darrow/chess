# frozen_string_literal: true

require_relative 'piece'

class Pawn < Piece
  attr_accessor :double_moved, :final_row, :en_passant_piece, :en_passant_square,
                :en_passant_destination, :double_move, :total_moves_when_double_moved

  def initialize(type, team, square)
    super
    @board_piece = @team == 'team_one' ? '♙' : "\u001b[31m♟"
    @double_move = nil
    @double_moved = false
    @en_passant_square = nil
    @en_passant_destination = nil
    @final_row = []
    @total_moves_when_double_moved = nil
  end

  def update_valid_moves(all_squares, other_player)
    @valid_moves = [] # Reset
    if @team == 'team_one'
      row_adj = 1
      row_adj_two = 2
      final_row = 8
    elsif @team == 'team_two'
      row_adj = -1
      row_adj_two = -2
      final_row = 1
    end

    l_diag = find("#{C[C.index(@square.column) - 1]}#{@square.row + row_adj}", all_squares)
    r_diag = find("#{C[C.index(@square.column) + 1]}#{@square.row + row_adj}", all_squares)

    # Normal move 1
    square_above = find("#{@square.column}#{@square.row + row_adj}", all_squares)
    @valid_moves << square_above if square_above && square_above.piece.nil?

    # Special_moves
    move_two(square_above, row_adj_two, all_squares) if @total_moves.zero?
    capture_left_diag(row_adj, l_diag)
    capture_right_diag(row_adj, r_diag)
    en_passant(all_squares, other_player, l_diag, r_diag)
    transform_pawn(final_row, all_squares) if @final_row.empty?
  end

  def move_two(square_above, row_adj_two, all_squares)
    two_above = find("#{@square.column}#{@square.row + row_adj_two}", all_squares)
    @valid_moves << two_above if two_above.piece.nil? && square_above.piece.nil?
    @double_move = two_above
  end

  def capture_left_diag(row_adj, l_diag)
    return unless l_diag && l_diag.piece && (C.index(@square.column) - 1) > -1 &&
                  (@square.row + row_adj).between?(1, 8) && l_diag.piece.team != @team

    @valid_moves << l_diag
  end

  def capture_right_diag(row_adj, r_diag)
    return unless r_diag && r_diag.piece && (C.index(@square.column) + 1) < 8 &&
                  (@square.row + row_adj).between?(1, 8) && r_diag.piece.team != @team

    @valid_moves << r_diag
  end

  def en_passant(all_squares, other_player, l_diag, r_diag)
    # Special rules: If your opponent double moves for their pawn's first move,
    # and that pawn ends adjacent to your pawn, you may capture it by moving to
    # the space it moved through in its double move. This must happen the turn
    # immediately after the double move.
    l = find("#{C[C.index(@square.column) - 1]}#{@square.row}", all_squares)
    r = find("#{C[C.index(@square.column) + 1]}#{@square.row}", all_squares)
    [l, r].each do |side|
      next if side.nil? || side.piece.nil? || side.piece.team == @team ||
              side.piece.type != 'pawn' || side.piece.double_moved == false ||
              side.piece.total_moves_when_double_moved != other_player.total_moves

      if side == r
        @valid_moves << r_diag
        @en_passant_square = r
        @en_passant_destination = r_diag
      elsif side == l
        @valid_moves << l_diag
        @en_passant_square = l
        @en_passant_destination = l_diag
      end
    end
  end

  def transform_pawn(final_row, all_squares)
    all_squares.each do |square|
      @final_row << square if square && square.row == final_row
    end
  end
end
