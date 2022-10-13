# frozen_string_literal: true

require_relative 'piece'

class Square
  attr_reader :coord, :styling, :row, :column
  attr_accessor :piece

  def initialize(styling, coord)
    @coord = coord
    @column = coord.split('').first
    @row = coord.split('').last.to_i
    @styling = styling
    @piece = nil
  end
end

class BoardCreator
  attr_accessor :game_board

  def initialize
    @game_board = create_board
    place_pieces
  end

  def create_board
    game_board = [[], [], [], [], [], [], [], []]
    # Populate the board subarrays (each representing a board row) with
    # Square objects, and assign each Square a color and coordinate
    styling = "\e[102m" # Green
    columns = %w[A B C D E F G H]
    n = 0
    game_board.each do
      for i in 0..7 do
        styling = (styling == "\e[47m" ? "\e[102m" : "\e[47m") unless i.zero?
        square = Square.new(styling, "#{columns[i]}#{n + 1}")
        game_board[n] << square
      end
      n += 1
    end
    game_board.reverse
  end

  def place_pieces
    @game_board[7].each do |square|
      case square.coord
      when 'A1'
        square.piece = Rook.new('rook', 'team_one', square)
      when 'B1'
        square.piece = Knight.new('knight', 'team_one', square)
      when 'C1'
        square.piece = Bishop.new('bishop', 'team_one', square)
      when 'D1'
        square.piece = Queen.new('queen', 'team_one', square)
      when 'E1'
        square.piece = King.new('king', 'team_one', square)
      when 'F1'
        square.piece = Bishop.new('bishop', 'team_one', square)
      when 'G1'
        square.piece = Knight.new('knight', 'team_one', square)
      when 'H1'
        square.piece = Rook.new('rook', 'team_one', square)
      end
    end
    @game_board[6].each { |square| square.piece = Pawn.new('pawn', 'team_one', square) }
    @game_board[1].each { |square| square.piece = Pawn.new('pawn', 'team_two', square) }
    @game_board[0].each do |square|
      case square.coord
      when 'A8'
        square.piece = Rook.new('rook', 'team_two', square)
      when 'B8'
        square.piece = Knight.new('knight', 'team_two', square)
      when 'C8'
        square.piece = Bishop.new('bishop', 'team_two', square)
      when 'D8'
        square.piece = King.new('king', 'team_two', square)
      when 'E8'
        square.piece = Queen.new('queen', 'team_two', square)
      when 'F8'
        square.piece = Bishop.new('bishop', 'team_two', square)
      when 'G8'
        square.piece = Knight.new('knight', 'team_two', square)
      when 'H8'
        square.piece = Rook.new('rook', 'team_two', square)
      end
    end
  end
end
