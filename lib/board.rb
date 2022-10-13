# frozen_string_literal: true

require_relative 'piece'

class Square
  attr_reader :color, :coord, :styling, :row, :column
  attr_accessor :piece

  def initialize(color, coord, column, row)
    @color = color
    @coord = coord
    @column = column
    @row = row
    @styling = color == 'green' ? "\e[102m" : "\e[47m"
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
    color = 'green'
    columns = %w[A B C D E F G H]
    n = 0
    game_board.each do |row|
      for i in 0..7 do
        color = (color == 'white' ? 'green' : 'white') unless i == 0
        square = Square.new(color, "#{columns[i]}#{n + 1}", "#{columns[i]}", "#{n + 1}".to_i)
        game_board[n] << square
      end
      n += 1
    end
    game_board.reverse
  end

  def place_pieces
    @game_board.each_with_index do |row, row_ind|
      if row_ind == 7
        row.each do |square|
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
      elsif row_ind == 6
        row.each { |square| square.piece = Pawn.new('pawn', 'team_one', square) }
      elsif row_ind == 1
        row.each { |square| square.piece = Pawn.new('pawn', 'team_two', square) }
      elsif row_ind == 0
        row.each do |square|
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
  end
end
