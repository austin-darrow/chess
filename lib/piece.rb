class Piece
  attr_reader :type, :team, :board_piece, :c
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

  def add_cardinal_squares(u, d, l, r, all_squares)
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

  def add_diagonal_squares(lu, ld, ru, rd, all_squares)
    lu, ld, ru, rd = [], [], [], [] # Diagonal squares
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
end

# =========================================================================
# =========================================================================

class Pawn < Piece
  attr_accessor :double_moved, :final_row, :en_passant_piece, :en_passant_square,
                :en_passant_destination, :double_move

  def initialize(type, team, square)
    super
    @board_piece = @team == 'team_one' ? "♙" : "\u001b[31m♟"
    @double_move = nil
    @double_moved = false
    @en_passant_square = nil
    @en_passant_destination = nil
    @final_row = nil
  end

  def update_valid_moves(all_squares)
    # Reset
    @valid_moves = []

    if @team == 'team_one'
      # Normal move 1
      square_above = find("#{@square.column}#{@square.row + 1}", all_squares)
      @valid_moves << square_above if square_above && square_above.piece.nil?

      # Move 2 if pawn hasn't moved yet
      if @total_moves.zero?
        two_above = find("#{@square.column}#{@square.row + 2}", all_squares)
        @valid_moves << two_above if two_above.piece.nil? && square_above.piece.nil?
        @double_move = two_above
      end

      # Capture enemy pieces if in diagonals 1 away
      if (C.index(@square.column) - 1) > -1 && (@square.row + 1) < 9
        left_up_diag = find("#{C[C.index(@square.column) - 1]}#{@square.row + 1}", all_squares)
        unless left_up_diag.nil? || left_up_diag.piece.nil? || left_up_diag.piece.team == @team
          @valid_moves << left_up_diag
        end
      end
      if (C.index(@square.column) + 1) < 8 && (@square.row + 1) < 9
        right_up_diag = find("#{C[C.index(@square.column) + 1]}#{@square.row + 1}", all_squares)
        unless right_up_diag.nil? || right_up_diag.piece.nil? || right_up_diag.piece.team == @team
          @valid_moves << right_up_diag
        end
      end

      # En passant special move
      l = find("#{C[C.index(@square.column) - 1]}#{@square.row}", all_squares)
      r = find("#{C[C.index(@square.column) + 1]}#{@square.row}", all_squares)
      [l, r].each do |side|
        unless side.nil? || side.piece.nil? || side.piece.team == @team
          if side.piece.type == 'pawn' && side.piece.double_moved == true
            if side == r
              @valid_moves << right_up_diag
              @en_passant_square = r
              @en_passant_destination = right_up_diag
            elsif side == l
              @valid_moves << left_up_diag
              @en_passant_square = l
              @en_passant_destination = left_up_diag
            end
          end
        end
      end

      # Transform if pawn moves to final row
      @valid_moves.each do |square|
        if square && square.row == 8
          @final_row = square
        end
      end

    elsif @team == 'team_two'
      # Normal move 1
      square_below = find("#{@square.column}#{@square.row - 1}" , all_squares)
      @valid_moves << square_below if square_below && square_below.piece.nil?

      # Move 2 if pawn hasn't moved yet
      if @total_moves.zero?
        two_below = find("#{@square.column}#{@square.row - 2}" , all_squares)
        @valid_moves << two_below if two_below.piece.nil? && square_below.piece.nil?
        @double_move = two_below
      end

      # Capture enemy pieces if in diagonals 1 away
      if (C.index(@square.column) - 1) > -1 && (@square.row - 1) > 0
        left_down_diag = find("#{C[C.index(@square.column) - 1]}#{@square.row - 1}" , all_squares)
        unless left_down_diag.nil? || left_down_diag.piece.nil? || left_down_diag.piece.team == @team
          @valid_moves << left_down_diag
        end
      end
      if (C.index(@square.column) + 1) < 8 && (@square.row - 1) > 0
        right_down_diag = find("#{C[C.index(@square.column) + 1]}#{@square.row - 1}" , all_squares)
        unless right_down_diag.nil? || right_down_diag.piece.nil? || right_down_diag.piece.team == @team
          @valid_moves << right_down_diag
        end
      end

      # En passant special move
      l = find("#{C[C.index(@square.column) - 1]}#{@square.row}", all_squares)
      r = find("#{C[C.index(@square.column) + 1]}#{@square.row}", all_squares)
      [l, r].each do |side|
        unless side.nil? || side.piece.nil? || side.piece.team == @team
          if side.piece.type == 'pawn' && side.piece.double_moved == true
            if side == r
              @valid_moves << right_down_diag
              @en_passant_square = r
              @en_passant_destination = right_down_diag
            elsif side == l
              @valid_moves << left_down_diag
              @en_passant_square = l
              @en_passant_destination = left_down_diag
            end
          end
        end
      end

      # Transform if pawn moves to final row
      @valid_moves.each do |square|
        if square && square.row == 1
          @final_row = square
        end
      end
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

  def update_valid_moves(all_squares)
    @valid_moves = [] # Reset
    u, d, l, r = add_cardinal_squares(u, d, l, r, all_squares)

    # Extract from each array only empty squares + first square with an enemy piece;
    # only knights can jump other pieces
    [l, d].each { |arr| arr.replace(remove_jumps(arr, 'negative')) }
    [r, u].each { |arr| arr.replace(remove_jumps(arr, 'positive')) }

    # Add all to @valid_moves and clean it up
    valid = [l, d, r, u].flatten.compact
    valid.select! { |sq| sq.piece ? sq.piece.team != @team : sq }
    @valid_moves = valid
  end
end

# =========================================================================
# =========================================================================

class Knight < Piece
  def initialize(type, team, square)
    super
    @board_piece = @team == 'team_one' ? '♘' : "\u001b[31m♞"
  end

  def update_valid_moves(all_squares)
    @valid_moves = [] # Reset

    # Select all potential 8 squares a knight could move to unless coordinates are off the board
    transformations = [[2, 1], [2, -1], [-2, 1], [-2, -1], [1, 2], [1, -2], [-1, 2], [-1, -2]]
    valid_coords = []
    transformations.each do |t|
      if (C.index(@square.column) + t[0]).between?(0, 7) && (@square.row + t[1]).between?(1, 8)
        valid_coords << [C[C.index(@square.column) + t[0]], (@square.row + t[1])].join
      end
    end

    # Convert array of valid coordinates into Square objects; add each to @valid_moves
    all_squares.each do |other_square|
      if valid_coords.any? { |c| c == other_square.coord }
        @valid_moves << other_square
      end
    end

    # Remove squares if they contain same team pieces
    @valid_moves.select! do |sq|
      sq.piece.nil? || sq.piece.team != @team
    end
  end
end

# =========================================================================
# =========================================================================

class Bishop < Piece
  def initialize(type, team, square)
    super
    @board_piece = @team == 'team_one' ? '♗' : "\u001b[31m♝"
  end

  def update_valid_moves(all_squares)
    @valid_moves = [] # Reset
    lu, ld, ru, rd = add_diagonal_squares(lu, ld, ru, rd, all_squares)

    # Extract from each array only empty squares + first square with an enemy piece;
    # only knights can jump other pieces
    [lu, ld, ru, rd].each { |arr| arr.replace(remove_jumps(arr)) }

    # Add all valid moves to array
    valid = [lu, ld, ru, rd].flatten.compact
    valid.select! { |sq| sq.piece ? sq.piece.team != @team : sq }
    @valid_moves = valid
  end
end

# =========================================================================
# =========================================================================

class Queen < Piece
  def initialize(type, team, square)
    super
    @board_piece = @team == 'team_one' ? '♕' : "\u001b[31m♛"
  end

  def update_valid_moves(all_squares)
    @valid_moves = [] # Reset
    lu, ld, ru, rd = add_diagonal_squares(lu, ld, ru, rd, all_squares)
    u, d, l, r = add_cardinal_squares(u, d, l, r, all_squares)

    # Extract from each array only empty squares + first square with an enemy piece;
    # only knights can jump other pieces
    [lu, ld, ru, rd].each { |arr| arr.replace(remove_jumps(arr)) }
    [l, d].each { |arr| arr.replace(remove_jumps(arr, 'negative')) }
    [r, u].each { |arr| arr.replace(remove_jumps(arr, 'positive')) }

    # Add all valid moves to array
    valid = [lu, ld, ru, rd, l, d, r, u].flatten.compact
    valid.select! { |sq| sq.piece ? sq.piece.team != @team : sq }
    @valid_moves = valid
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

  def update_valid_moves(all_squares)
    @valid_moves = [] # Reset
    transformations = [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]]

    transformations.each do |t|
      if (C.index(@square.column) + t[0]).between?(0, 7) && (@square.row + t[1]).between?(1, 8)
        @valid_moves << find("#{C[C.index(@square.column) + t[0]]}#{@square.row + t[1]}", all_squares)
      end
    end

    # Select only moves that don't include same team pieces
    @valid_moves.select! { |sq| sq.piece ? sq.piece.team != @team : sq }

    # Castle special move
    if @total_moves > 0
      @left_castle = nil
      @right_castle = nil
      return
    end

    enemy_moves = []
    pieces = []
    all_squares.each do |sq|
      next if sq.piece.nil?
      pieces << sq.piece
    end
    enemy_pieces = pieces.select { |p| p.team != @team }
    enemy_pieces.each { |p| p.valid_moves.each { |move| enemy_moves << move } }
    if @team == 'team_one'
      l = [find("#{C[C.index(@square.column) - 1]}#{@square.row}", all_squares),
           find("#{C[C.index(@square.column) - 2]}#{@square.row}", all_squares),
           find("#{C[C.index(@square.column) - 3]}#{@square.row}", all_squares),
           find("#{C[C.index(@square.column) - 4]}#{@square.row}", all_squares)]
      l_rook = l[3].piece if l[3].piece
      if l[0..2].all? { |sq| sq.piece.nil? } && l_rook && l_rook.total_moves.zero? &&
         @total_moves.zero? && l[0..1].each { |sq| enemy_moves.none?(sq) } &&
         enemy_moves.none?(@square)
        @left_castle = l[1]
        @valid_moves << l[1]
        @left_rook_square = l_rook.square
        @left_rook_destination = l[0]
      end

      r = [find("#{C[C.index(@square.column) + 1]}#{@square.row}", all_squares),
           find("#{C[C.index(@square.column) + 2]}#{@square.row}", all_squares),
           find("#{C[C.index(@square.column) + 3]}#{@square.row}", all_squares)]
      r_rook = r[2].piece if l[2].piece
      if r[0..1].all? { |sq| sq.piece.nil? } && r_rook && r_rook.total_moves.zero? &&
         @total_moves.zero? && r[0..1].each { |sq| enemy_moves.none?(sq) } &&
         enemy_moves.none?(@square)
        @right_castle = r[1]
        @valid_moves << r[1]
        @right_rook_square = r_rook.square
        @right_rook_destination = r[0]
      end
    elsif @team == 'team_two'
      l = [find("#{C[C.index(@square.column) - 1]}#{@square.row}", all_squares),
           find("#{C[C.index(@square.column) - 2]}#{@square.row}", all_squares),
           find("#{C[C.index(@square.column) - 3]}#{@square.row}", all_squares)]
      l_rook = l[2].piece if l[2].piece
      if l[0..1].all? { |sq| sq.piece.nil? } && l_rook && l_rook.total_moves.zero? &&
         @total_moves.zero? && l[0..1] { |sq| enemy_moves.none?(sq) } &&
         enemy_moves.none?(@square)
        @left_castle = l[1]
        @valid_moves << l[1]
        @left_rook_square = l_rook.square
        @left_rook_destination = l[0]
      end

      r = [find("#{C[C.index(@square.column) + 1]}#{@square.row}", all_squares),
           find("#{C[C.index(@square.column) + 2]}#{@square.row}", all_squares),
           find("#{C[C.index(@square.column) + 3]}#{@square.row}", all_squares),
           find("#{C[C.index(@square.column) + 4]}#{@square.row}", all_squares)]
      r_rook = r[3].piece if r[3].piece
      if r[0..2].all? { |sq| sq.piece.nil? } && r_rook && r_rook.total_moves.zero? &&
         @total_moves.zero? && r[0..1] { |sq| enemy_moves.none?(sq) } &&
         enemy_moves.none?(@square)
        @right_castle = r[1]
        @valid_moves << r[1]
        @right_rook_square = r_rook.square
        @right_rook_destination = r[0]
      end
    end
  end
end
