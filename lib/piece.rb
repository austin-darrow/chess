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
end

# =========================================================================
# =========================================================================

class Pawn < Piece
  def initialize(type, team, square)
    super
    @board_piece = @team == 'team_one' ? "♙" : "\u001b[31m♟"
  end

  def update_valid_moves(all_squares)
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
    valid_l << l.first unless l.empty? || @team == l.first.piece.team

    # From r array
    r.sort! { |a, b| a.coord <=> b.coord }
    valid_r = r.take_while { |sq| sq.piece.nil? }
    r -= valid_r
    valid_r << r.first unless r.empty? || @team == r.first.piece.team

    # From u array
    u.sort! { |a, b| a.coord <=> b.coord }
    valid_u = u.take_while { |sq| sq.piece.nil? }
    u -= valid_u
    valid_u << u.first unless u.empty? || @team == u.first.piece.team

    # From d array
    d.sort! { |a, b| b.coord <=> a.coord }
    valid_d = d.take_while { |sq| sq.piece.nil? }
    d -= valid_d
    valid_d << d.first unless d.empty? || @team == d.first.piece.team

    # Add all to @valid_moves and clean it up
    @valid_moves << valid_l + valid_r + valid_u + valid_d
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
    letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
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
  end
end

# =========================================================================
# =========================================================================

class King < Piece
  def initialize(type, team, square)
    super
    @board_piece = @team == 'team_one' ? '♔' : "\u001b[31m♚"
  end

  def update_valid_moves(all_squares)
  end
end
