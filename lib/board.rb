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
  end

  def create_board
    board = [[], [], [], [], [], [], [], []]
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

  def display_board
    puts %x(/usr/bin/clear)
    puts '   A  B  C  D  E  F  G  H '
    n = 8
    @board.each do |row|
      display = ""
      row.each { |square| display << "#{square.styling} P " }
      puts "#{n} #{display}\e[0m #{n}"
      n -= 1
    end
    puts "   A  B  C  D  E  F  G  H \n\n\n"
  end
end
