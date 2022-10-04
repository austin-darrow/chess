require_relative 'piece'

class Square
  attr_reader :color, :coord, :styling
  attr_accessor :piece

  def initialize(color, coord)
    @color = color
    @coord = coord
    @styling = color == 'green' ? "\e[102m" : "\e[47m"
    @piece = nil
  end
end

class Board
  attr_accessor :board

  def initialize
    @board = create_board
    place_pieces
  end

  def create_board
    board = [[], [], [], [], [], [], [], []]

    # Populate the board subarrays (each representing a board row) with
    # Square objects, and assign each Square a color and coordinate
    color = 'green'
    letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
    n = 0
    board.each do |row|
      for i in 0..7 do
        color = (color == 'white' ? 'green' : 'white') unless i == 0
        square = Square.new(color, "#{letters[i]}#{n + 1}")
        board[n] << square
      end
      n += 1
    end
    board.reverse
  end

  def place_pieces
    @board.each_with_index do |row, row_ind|
      if row_ind == 7
        row.each do |square|
          case square.coord
          when 'A1'
            square.piece = Piece.new('rook', 'white', square.coord)
          when 'B1'
            square.piece = Piece.new('knight', 'white', square.coord)
          when 'C1'
            square.piece = Piece.new('bishop', 'white', square.coord)
          when 'D1'
            square.piece = Piece.new('queen', 'white', square.coord)
          when 'E1'
            square.piece = Piece.new('king', 'white', square.coord)
          when 'F1'
            square.piece = Piece.new('bishop', 'white', square.coord)
          when 'G1'
            square.piece = Piece.new('knight', 'white', square.coord)
          when 'H1'
            square.piece = Piece.new('rook', 'white', square.coord)
          end
        end
      elsif row_ind == 6
        row.each { |square| square.piece = Piece.new('pawn', 'white', square.coord) }
      elsif row_ind == 1
        row.each { |square| square.piece = Piece.new('pawn', 'black', square.coord) }
      elsif row_ind == 0
        row.each do |square|
          case square.coord
          when 'A8'
            square.piece = Piece.new('rook', 'black', square.coord)
          when 'B8'
            square.piece = Piece.new('knight', 'black', square.coord)
          when 'C8'
            square.piece = Piece.new('bishop', 'black', square.coord)
          when 'D8'
            square.piece = Piece.new('king', 'black', square.coord)
          when 'E8'
            square.piece = Piece.new('queen', 'black', square.coord)
          when 'F8'
            square.piece = Piece.new('bishop', 'black', square.coord)
          when 'G8'
            square.piece = Piece.new('knight', 'black', square.coord)
          when 'H8'
            square.piece = Piece.new('rook', 'black', square.coord)
          end
        end
      end
    end
  end

  def display_board
    puts %x(/usr/bin/clear)
    puts '   A  B  C  D  E  F  G  H '
    n = 8
    @board.each do |row|
      display = ""
      row.each  do |square|
        if square.piece.nil?
          display << "#{square.styling}   "
        else
          display << "#{square.styling} #{square.piece.board_piece} "
        end
      end
      puts "#{n} #{display}\e[0m #{n}"
      n -= 1
    end
    puts "   A  B  C  D  E  F  G  H \n\n\n"
  end
end
