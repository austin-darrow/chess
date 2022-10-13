# frozen_string_literal: true

class Piece
  attr_reader :type, :team, :board_piece
  attr_accessor :square, :total_moves, :valid_moves

  C = %w[A B C D E F G H].freeze

  def initialize(type, team, square)
    @type = type
    @team = team
    @square = square
    @total_moves = 0
    @valid_moves = []
  end

  def find(coord, squares)
    squares.select { |sq| sq.coord == coord }.first
  end

  # Removes any squares beyond the first square containing a piece. Keeps that
  # square if it's an enemy piece; omits if its the same team.
  def remove_jumps(full_array, sort = nil)
    case sort
    when 'positive'
      full_array.sort! { |a, b| a.coord <=> b.coord }
    when 'negative'
      full_array.sort! { |a, b| b.coord <=> a.coord }
    end

    valid_arr = full_array.take_while { |sq| sq.piece.nil? }
    full_array -= valid_arr
    valid_arr << full_array.first
  end

  def add_cardinal_squares(all_squares)
    u, d, l, r = [], [], [], []
    all_squares.each do |other_square|
      if @square.row == other_square.row
        if @square.column > other_square.column
          l << other_square
        elsif @square.column < other_square.column
          r << other_square
        end
      end
      if @square.column == other_square.column
        if @square.row > other_square.row
          d << other_square
        elsif @square.row < other_square.row
          u << other_square
        end
      end
    end
    [u, d, l, r]
  end

  def add_diagonal_squares(all_squares)
    lu, ld, ru, rd = [], [], [], []
    for i in 1..7 do
      x = C.index(@square.column)
      y = @square.row
      lu << find("#{C[x - i]}#{y + i}", all_squares) if (x - i > -1) && (y + i < 9)
      ld << find("#{C[x - i]}#{y - i}", all_squares) if (x - i > -1) && (y - i > 0)
      ru << find("#{C[x + i]}#{y + i}", all_squares) if (x + i < 8) && (y + i < 9)
      rd << find("#{C[x + i]}#{y - i}", all_squares) if (x + i < 8) && (y - i > 0)
    end
    [lu, ld, ru, rd]
  end

  # Flatten, remove nils, and remove pieces of the same team
  def clean_valid_moves(*unclean)
    valid = [unclean].flatten.compact
    valid.select! { |sq| sq.piece ? sq.piece.team != @team : sq }
    valid.flatten.compact
    valid
  end
end

# =========================================================================
# =========================================================================

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

# =========================================================================
# =========================================================================

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

# =========================================================================
# =========================================================================

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

# =========================================================================
# =========================================================================

class Bishop < Piece
  def initialize(type, team, square)
    super
    @board_piece = @team == 'team_one' ? '♗' : "\u001b[31m♝"
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

# =========================================================================
# =========================================================================

class Queen < Piece
  def initialize(type, team, square)
    super
    @board_piece = @team == 'team_one' ? '♕' : "\u001b[31m♛"
  end

  def update_valid_moves(all_squares, _other_player)
    @valid_moves = [] # Reset
    lu, ld, ru, rd = add_diagonal_squares(all_squares)
    u, d, l, r = add_cardinal_squares(all_squares)

    # Extract from each array only empty squares + first square with an enemy piece;
    # only knights can jump other pieces
    [lu, ld, ru, rd].each { |arr| arr.replace(remove_jumps(arr)) }
    [l, d].each { |arr| arr.replace(remove_jumps(arr, 'negative')) }
    [r, u].each { |arr| arr.replace(remove_jumps(arr, 'positive')) }

    @valid_moves = clean_valid_moves(lu, ld, ru, rd, l, d, r, u)
  end
end

# =========================================================================
# =========================================================================

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
