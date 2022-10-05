require_relative 'board'

class Game
  attr_accessor :board

  def initialize
    @board = BoardCreator.new.game_board
  end

  def update_valid_moves

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
