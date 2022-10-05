class Piece
  attr_reader :type, :team, :board_piece
  attr_accessor :square, :total_moves

  def initialize(type, team, square)
    @type = type
    @team = team
    @square = square
    @total_moves = 0
  end
end

class Pawn < Piece
  def initialize(type, team, square)
    super
    @board_piece = @team == 'team_one' ? "♙" : "\u001b[31m♟"
  end

  def valid_moves(board, current_square)
    valid_moves = []
    if @total_moves == 0
      # valid_moves << 2 spaces forward
      # Should the board spaces keep track of where the pieces are? Or should the
      # pieces keep track of what space they are on + have a list of other spaces?
    end
  end
end

class Rook < Piece
  def initialize(type, team, square)
    super
    @board_piece = @team == 'team_one' ? '♖' : "\u001b[31m♜"
  end
end

class Knight < Piece
  def initialize(type, team, square)
    super
    @board_piece = @team == 'team_one' ? '♘' : "\u001b[31m♞"
  end
end

class Bishop < Piece
  def initialize(type, team, square)
    super
    @board_piece = @team == 'team_one' ? '♗' : "\u001b[31m♝"
  end
end

class Queen < Piece
  def initialize(type, team, square)
    super
    @board_piece = @team == 'team_one' ? '♕' : "\u001b[31m♛"
  end
end

class King < Piece
  def initialize(type, team, square)
    super
    @board_piece = @team == 'team_one' ? '♔' : "\u001b[31m♚"
  end
end
