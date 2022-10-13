# frozen_string_literal: true

require_relative 'piece'

class King < Piece
  attr_accessor :left_castle, :left_rook_destination, :left_rook_square,
                :right_castle, :right_rook_destination, :right_rook_square

  def initialize(type, team, square)
    super
    @board_piece = @team == 'team_one' ? '♔' : "\u001b[31m♚"
    @left_castle = nil
    @left_rook_square = nil
    @left_rook_destination = nil
    @right_castle = nil
    @right_rook_square = nil
    @right_rook_destination = nil
  end

  def update_valid_moves(all_squares, _other_player)
    @valid_moves = [] # Reset
    @left_castle = nil
    @right_castle = nil

    # Normal move 1 in any direction
    transformations = [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]]
    transformations.each do |t|
      next unless (C.index(@square.column) + t[0]).between?(0, 7) && (@square.row + t[1]).between?(1, 8)

      @valid_moves << find("#{C[C.index(@square.column) + t[0]]}#{@square.row + t[1]}", all_squares)
    end
    @valid_moves = clean_valid_moves(@valid_moves)

    # Castle special move
    castle(all_squares) if @total_moves.zero?
  end

  def get_pieces(all_squares)
    pieces = []
    all_squares.each do |sq|
      next if sq.piece.nil?

      pieces << sq.piece
    end
    pieces
  end

  def get_enemy_moves(all_squares)
    enemy_moves = []
    pieces = get_pieces(all_squares)

    enemy_pieces = pieces.reject { |p| p.team == @team }
    enemy_pieces.each { |p| p.valid_moves.each { |move| enemy_moves << move } }
  end

  def castle(all_squares)
    # Castling rules: the king hasn't moved, the rook hasn't moved, there are no
    # pieces between the two, the king is not in check, and the king would not be
    # in check in any of the spaces it has to move through to castle

    enemy_moves = get_enemy_moves(all_squares)
    return if enemy_moves.any?(@square)

    # Get all squares in the same row as the king
    l = [find("#{C[C.index(@square.column) - 1]}#{@square.row}", all_squares),
         find("#{C[C.index(@square.column) - 2]}#{@square.row}", all_squares),
         find("#{C[C.index(@square.column) - 3]}#{@square.row}", all_squares)]
    r = [find("#{C[C.index(@square.column) + 1]}#{@square.row}", all_squares),
         find("#{C[C.index(@square.column) + 2]}#{@square.row}", all_squares),
         find("#{C[C.index(@square.column) + 3]}#{@square.row}", all_squares)]
    if @team == 'team_one'
      l << find("#{C[C.index(@square.column) - 4]}#{@square.row}", all_squares)
    elsif @team == 'team_two'
      r << find("#{C[C.index(@square.column) + 4]}#{@square.row}", all_squares)
    end

    # If the squares meet castling criteria, add to @valid_moves and update helper variables
    l_rook = l.last.piece if l.last.piece
    if l[0..-2].all? { |sq| sq.piece.nil? } && l_rook && l_rook.total_moves.zero? &&
        @total_moves.zero? && l[0..1].each { |sq| enemy_moves.none?(sq) }
      @left_castle = l[1]
      @valid_moves << l[1]
      @left_rook_square = l_rook.square
      @left_rook_destination = l[0]
    end
    r_rook = r.last.piece if r.last.piece
    if r[0..-2].all? { |sq| sq.piece.nil? } && r_rook && r_rook.total_moves.zero? &&
        @total_moves.zero? && r[0..1].each { |sq| enemy_moves.none?(sq) }
      @right_castle = r[1]
      @valid_moves << r[1]
      @right_rook_square = r_rook.square
      @right_rook_destination = r[0]
    end
  end
end
