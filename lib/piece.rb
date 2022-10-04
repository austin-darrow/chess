class Piece
  attr_reader :type, :team, :board_piece
  attr_accessor :coord

  def initialize(type, team, coord)
    @type = type
    @team = team
    @coord = coord
    @board_piece = assign_piece
  end

  def assign_piece
    if @team == 'black'
      case @type
      when 'king'
        '♚'
      when 'queen'
        '♛'
      when 'bishop'
        '♝'
      when 'knight'
        '♞'
      when 'rook'
        '♜'
      when 'pawn'
        '♟'
      end
    elsif @team == 'white'
      case @type
      when 'king'
        '♔'
      when 'queen'
        '♕'
      when 'bishop'
        '♗'
      when 'knight'
        '♘'
      when 'rook'
        '♖'
      when 'pawn'
        '♙'
      end
    end
  end
end
