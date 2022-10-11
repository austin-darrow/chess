class Piece
  attr_reader :type, :team, :board_piece
  attr_accessor :square, :total_moves, :valid_moves

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
    current_column = @square.column
    current_row = @square.row
    c = %w[A B C D E F G H]
    current_c_ind = c.index(current_column)

    if @team == 'team_one'
      # Normal move 1
      square_above = find("#{current_column}#{current_row + 1}", all_squares)
      @valid_moves << square_above if square_above && square_above.piece.nil?

      # Move 2 if pawn hasn't moved yet
      if @total_moves.zero?
        two_above = find("#{current_column}#{current_row + 2}", all_squares)
        @valid_moves << two_above if two_above.piece.nil? && square_above.piece.nil?
        @double_move = two_above
      end

      # Capture enemy pieces if in diagonals 1 away
      if (current_c_ind - 1) > -1 && (current_row + 1) < 9
        left_up_diag = find("#{c[current_c_ind - 1]}#{current_row + 1}", all_squares)
        unless left_up_diag.nil? || left_up_diag.piece.nil? || left_up_diag.piece.team == @team
          @valid_moves << left_up_diag
        end
      end
      if (current_c_ind + 1) < 8 && (current_row + 1) < 9
        right_up_diag = find("#{c[current_c_ind + 1]}#{current_row + 1}", all_squares)
        unless right_up_diag.nil? || right_up_diag.piece.nil? || right_up_diag.piece.team == @team
          @valid_moves << right_up_diag
        end
      end

      # En passant special move
      l = find("#{c[current_c_ind - 1]}#{current_row}", all_squares)
      r = find("#{c[current_c_ind + 1]}#{current_row}", all_squares)
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
      square_below = find("#{current_column}#{current_row - 1}" , all_squares)
      @valid_moves << square_below if square_below && square_below.piece.nil?

      # Move 2 if pawn hasn't moved yet
      if @total_moves.zero?
        two_below = find("#{current_column}#{current_row - 2}" , all_squares)
        @valid_moves << two_below if two_below.piece.nil? && square_below.piece.nil?
        @double_move = two_below
      end

      # Capture enemy pieces if in diagonals 1 away
      if (current_c_ind - 1) > -1 && (current_row - 1) > 0
        left_down_diag = find("#{c[current_c_ind - 1]}#{current_row - 1}" , all_squares)
        unless left_down_diag.nil? || left_down_diag.piece.nil? || left_down_diag.piece.team == @team
          @valid_moves << left_down_diag
        end
      end
      if (current_c_ind + 1) < 8 && (current_row - 1) > 0
        right_down_diag = find("#{c[current_c_ind + 1]}#{current_row - 1}" , all_squares)
        unless right_down_diag.nil? || right_down_diag.piece.nil? || right_down_diag.piece.team == @team
          @valid_moves << right_down_diag
        end
      end

      # En passant special move
      l = find("#{c[current_c_ind - 1]}#{current_row}", all_squares)
      r = find("#{c[current_c_ind + 1]}#{current_row}", all_squares)
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
    # Reset
    @valid_moves = []
    l = []
    r = []
    u = []
    d = []

    current_r = @square.row
    current_c = @square.column

    # Add other squares to l array if they are left of current, or r array if right
    all_squares.each do |other_square|
      other_r = other_square.row
      other_c = other_square.column
      if current_r == other_r
        if current_c > other_c
          l << other_square
        elsif current_c < other_c
          r << other_square
        end
      end
      if current_c == other_c
        if current_r > other_r
          d << other_square
        elsif current_r < other_r
          u << other_square
        end
      end
    end

    # Extract from l array only empty squares + first square with an enemy piece, as
    # rooks cannot jump other pieces
    l.sort! { |a, b| b.coord <=> a.coord }
    valid_l = l.take_while { |sq| sq.piece.nil? }
    l -= valid_l
    valid_l << l.first

    # From r array
    r.sort! { |a, b| a.coord <=> b.coord }
    valid_r = r.take_while { |sq| sq.piece.nil? }
    r -= valid_r
    valid_r << r.first

    # From u array
    u.sort! { |a, b| a.coord <=> b.coord }
    valid_u = u.take_while { |sq| sq.piece.nil? }
    u -= valid_u
    valid_u << u.first

    # From d array
    d.sort! { |a, b| b.coord <=> a.coord }
    valid_d = d.take_while { |sq| sq.piece.nil? }
    d -= valid_d
    valid_d << d.first

    # Add all to @valid_moves and clean it up
    valid = [valid_l, valid_r, valid_u, valid_d].flatten.compact
    valid.select! { |sq| sq.piece ? sq.piece.team != @team : sq }
    @valid_moves << valid
    @valid_moves.flatten!.compact!
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
    current_r = @square.row
    current_c = @square.column
    letters = %w[A B C D E F G H]
    current_c_ind = letters.index(current_c)
    transformations = [[2, 1], [2, -1], [-2, 1], [-2, -1], [1, 2], [1, -2], [-1, 2], [-1, -2]]
    valid_coords = []
    transformations.each do |t|
      if (current_c_ind + t[0]).between?(0, 7) && (current_r + t[1]).between?(1, 8)
        valid_coords << [letters[current_c_ind + t[0]], (current_r + t[1])].join
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
    # Reset
    @valid_moves = []
    c = %w[A B C D E F G H]
    current_c_ind = c.index(@square.column)
    current_r = @square.row


    # Get Squares using coordinates for diagonals in all 4 directions
    ru = [] # Diagonal right/up (quadrant 1)
    rd = [] # Diagonal right/down (quadrant 2)
    ld = [] # Diagonal left/down (quadrant 3)
    lu = [] # Diagonal left/up (quadrant 4)
    for i in 1..7 do
      ru << find("#{c[current_c_ind + i]}#{current_r + i}", all_squares) if (current_c_ind + i < 8) && (current_r + i < 9)
      rd << find("#{c[current_c_ind + i]}#{current_r - i}", all_squares) if (current_c_ind + i < 8) && (current_r - i > 0)
      ld << find("#{c[current_c_ind - i]}#{current_r - i}", all_squares) if (current_c_ind - i > -1) && (current_r - i > 0)
      lu << find("#{c[current_c_ind - i]}#{current_r + i}", all_squares) if (current_c_ind - i > -1) && (current_r + i < 9)
    end

    # Extract from ru array only empty squares + first square with an enemy piece, as
    # bishops cannot jump other pieces
    valid_ru = ru.take_while { |sq| sq.piece.nil? }
    ru -= valid_ru
    valid_ru << ru.first

    # From rd array
    valid_rd = rd.take_while { |sq| sq.piece.nil? }
    rd -= valid_rd
    valid_rd << rd.first

    # From ld array
    valid_ld = ld.take_while { |sq| sq.piece.nil? }
    ld -= valid_ld
    valid_ld << ld.first

    # From lu array
    valid_lu = lu.take_while { |sq| sq.piece.nil? }
    lu -= valid_lu
    valid_lu << lu.first

    # Add all valid moves to array
    valid = [valid_ru, valid_rd, valid_ld, valid_lu].flatten.compact
    valid.select! { |sq| sq.piece ? sq.piece.team != @team : sq }
    all_squares.each do |other_square|
      @valid_moves << other_square if valid.include?(other_square)
    end
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
    # Reset
    @valid_moves = []
    c = %w[A B C D E F G H]
    current_c_ind = c.index(@square.column)
    current_r = @square.row
    current_c = @square.column


    # Get Squares using coordinates for all directions
    ru = [] # Diagonal right/up (quadrant 1)
    rd = [] # Diagonal right/down (quadrant 2)
    ld = [] # Diagonal left/down (quadrant 3)
    lu = [] # Diagonal left/up (quadrant 4)
    l = []
    r = []
    u = []
    d = []

    # Add squares to diagonal arrays
    for i in 1..7 do
      ru << find("#{c[current_c_ind + i]}#{current_r + i}", all_squares) if (current_c_ind + i < 8) && (current_r + i < 9)
      rd << find("#{c[current_c_ind + i]}#{current_r - i}", all_squares) if (current_c_ind + i < 8) && (current_r - i > 0)
      ld << find("#{c[current_c_ind - i]}#{current_r - i}", all_squares) if (current_c_ind - i > -1) && (current_r - i > 0)
      lu << find("#{c[current_c_ind - i]}#{current_r + i}", all_squares) if (current_c_ind - i > -1) && (current_r + i < 9)
    end

    # Add squares to cardinal arrays
    all_squares.each do |other_square|
      other_r = other_square.row
      other_c = other_square.column
      if current_r == other_r
        if current_c > other_c
          l << other_square
        elsif current_c < other_c
          r << other_square
        end
      end
      if current_c == other_c
        if current_r > other_r
          d << other_square
        elsif current_r < other_r
          u << other_square
        end
      end
    end

    # Extract from ru array only empty squares + first square with an enemy piece, as
    # queens cannot jump other pieces
    valid_ru = ru.take_while { |sq| sq.piece.nil? }
    ru -= valid_ru
    valid_ru << ru.first

    # From rd array
    valid_rd = rd.take_while { |sq| sq.piece.nil? }
    rd -= valid_rd
    valid_rd << rd.first

    # From ld array
    valid_ld = ld.take_while { |sq| sq.piece.nil? }
    ld -= valid_ld
    valid_ld << ld.first

    # From lu array
    valid_lu = lu.take_while { |sq| sq.piece.nil? }
    lu -= valid_lu
    valid_lu << lu.first

    # From l array
    l.sort! { |a, b| b.coord <=> a.coord }
    valid_l = l.take_while { |sq| sq.piece.nil? }
    l -= valid_l
    valid_l << l.first

    # From r array
    r.sort! { |a, b| a.coord <=> b.coord }
    valid_r = r.take_while { |sq| sq.piece.nil? }
    r -= valid_r
    valid_r << r.first

    # From u array
    u.sort! { |a, b| a.coord <=> b.coord }
    valid_u = u.take_while { |sq| sq.piece.nil? }
    u -= valid_u
    valid_u << u.first

    # From d array
    d.sort! { |a, b| b.coord <=> a.coord }
    valid_d = d.take_while { |sq| sq.piece.nil? }
    d -= valid_d
    valid_d << d.first


    # Add all valid moves to array
    valid = [valid_ru, valid_rd, valid_ld, valid_lu, valid_l, valid_r, valid_u, valid_d].flatten.compact
    valid.select! { |sq| sq.piece ? sq.piece.team != @team : sq }
    all_squares.each do |other_square|
      @valid_moves << other_square if valid.include?(other_square)
    end
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
    # Reset
    @valid_moves = []
    c = %w[A B C D E F G H]
    current_c_ind = c.index(@square.column)
    current_r = @square.row
    transformations = [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]]

    transformations.each do |t|
      if (current_c_ind + t[0]).between?(0, 7) && (current_r + t[1]).between?(1, 8)
        @valid_moves << find("#{c[current_c_ind + t[0]]}#{current_r + t[1]}", all_squares)
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
      l = [find("#{c[current_c_ind - 1]}#{current_r}", all_squares),
           find("#{c[current_c_ind - 2]}#{current_r}", all_squares),
           find("#{c[current_c_ind - 3]}#{current_r}", all_squares),
           find("#{c[current_c_ind - 4]}#{current_r}", all_squares)]
      l_rook = l[3].piece if l[3].piece
      if l[0..2].all? { |sq| sq.piece.nil? } && l_rook && l_rook.total_moves.zero? &&
         @total_moves.zero? && l[0..1].each { |sq| enemy_moves.none?(sq) } &&
         enemy_moves.none?(@square)
        @left_castle = l[1]
        @valid_moves << l[1]
        @left_rook_square = l_rook.square
        @left_rook_destination = l[0]
      end

      r = [find("#{c[current_c_ind + 1]}#{current_r}", all_squares),
           find("#{c[current_c_ind + 2]}#{current_r}", all_squares),
           find("#{c[current_c_ind + 3]}#{current_r}", all_squares)]
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
      l = [find("#{c[current_c_ind - 1]}#{current_r}", all_squares),
           find("#{c[current_c_ind - 2]}#{current_r}", all_squares),
           find("#{c[current_c_ind - 3]}#{current_r}", all_squares)]
      l_rook = l[2].piece if l[2].piece
      if l[0..1].all? { |sq| sq.piece.nil? } && l_rook && l_rook.total_moves.zero? &&
         @total_moves.zero? && l[0..1] { |sq| enemy_moves.none?(sq) } &&
         enemy_moves.none?(@square)
        @left_castle = l[1]
        @valid_moves << l[1]
        @left_rook_square = l_rook.square
        @left_rook_destination = l[0]
      end

      r = [find("#{c[current_c_ind + 1]}#{current_r}", all_squares),
           find("#{c[current_c_ind + 2]}#{current_r}", all_squares),
           find("#{c[current_c_ind + 3]}#{current_r}", all_squares),
           find("#{c[current_c_ind + 4]}#{current_r}", all_squares)]
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
