require_relative 'piece'

class Square
  attr_reader :color, :coord, :styling, :row, :column
  attr_accessor :piece, :verticals, :horizontals, :diagonals, :knight_moves

  def initialize(color, coord, column, row)
    @color = color
    @coord = coord
    @column = column
    @row = row
    @styling = color == 'green' ? "\e[102m" : "\e[47m"
    @piece = nil
    @verticals = []
    @horizontals = []
    @diagonals = []
    @knight_moves = []
  end
end

class BoardCreator
  attr_accessor :game_board

  def initialize
    @game_board = create_board
    place_pieces
    # add_diagonals
    # update_horizontals
    # add_verticals
    # add_knight_moves
  end

  def create_board
    game_board = [[], [], [], [], [], [], [], []]

    # Populate the board subarrays (each representing a board row) with
    # Square objects, and assign each Square a color and coordinate
    color = 'green'
    letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
    n = 0
    game_board.each do |row|
      for i in 0..7 do
        color = (color == 'white' ? 'green' : 'white') unless i == 0
        square = Square.new(color, "#{letters[i]}#{n + 1}", "#{letters[i]}", "#{n + 1}".to_i)
        game_board[n] << square
      end
      n += 1
    end
    game_board.reverse
  end

  # def add_verticals
  #   @game_board.flatten.each do |current_square|
  #     current_column = current_square.coord.split('').first
  #     @game_board.flatten.each do |other_square|
  #       other_column = other_square.coord.split('').first
  #       if current_column == other_column
  #         current_square.verticals << other_square unless other_square == current_square
  #       end
  #     end
  #   end
  # end

  # def update_horizontals
  #   @game_board.flatten.each do |current_square|
  #     current_square.horizontals = [] # Reset
  #     current_row = current_square.coord.split('').last
  #     current_column = current_square.coord.split('').first

  #     # Add other squares to l array if they are left of current, or r array if right
  #     l = []
  #     r = []
  #     @game_board.flatten.each do |other_square|
  #       other_row = other_square.coord.split('').last
  #       other_column = other_square.coord.split('').first
  #       if current_row == other_row
  #         if current_column > other_column
  #           l << other_square
  #         elsif current_column < other_column
  #           r << other_square
  #         end
  #       end
  #     end

  #     # Extract from l array only empty squares + first square with a piece, as
  #     # no pieces that move horizontally can jump other pieces
  #     l.sort! { |a, b| a.coord <=> b.coord }.reverse!
  #     valid_l = l.take_while { |sq| sq.piece.nil? }
  #     l = l - valid_l
  #     valid_l << l.shift unless l.empty?

  #     # Same as above but from r array
  #     r.sort! { |a, b| a.coord <=> b.coord }
  #     valid_r = r.take_while { |sq| sq.piece.nil? }
  #     r = r - valid_r
  #     valid_r << r.shift unless r.empty?

  #     current_square.horizontals << valid_l
  #     current_square.horizontals << valid_r
  #     current_square.horizontals.flatten!.compact!
  #   end
  # end

  # def add_diagonals
  #   @game_board.flatten.each do |current_square|
  #     current_column = current_square.coord.split('').first
  #     current_row = current_square.coord.split('').last

  #     c = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
  #     r = ['1', '2', '3', '4', '5', '6', '7', '8']
  #     current_c_ind = c.index(current_column)
  #     current_r_ind = r.index(current_row)
  #     transformations = []
  #     n = 1
  #     7.times do
  #       transformations << "#{c[current_c_ind - n]}#{r[current_r_ind - n]}" unless (current_c_ind - n < 0) || (current_r_ind - n < 0)
  #       transformations << "#{c[current_c_ind + n]}#{r[current_r_ind + n]}" unless (current_c_ind + n > 7) || (current_r_ind + n > 7)
  #       transformations << "#{c[current_c_ind - n]}#{r[current_r_ind + n]}" unless (current_c_ind - n < 0) || (current_r_ind + n > 7)
  #       transformations << "#{c[current_c_ind + n]}#{r[current_r_ind - n]}" unless (current_c_ind + n > 7) || (current_r_ind - n < 0)
  #       n += 1
  #     end

  #     @game_board.flatten.each do |other_square|
  #       current_square.diagonals << other_square if transformations.include?(other_square.coord)
  #     end
  #   end
  # end

  # def add_knight_moves
  #   @game_board.flatten.each do |current_square|
  #     current_column = current_square.coord.split('').first
  #     current_row = current_square.coord.split('').last

  #     c = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
  #     r = ['1', '2', '3', '4', '5', '6', '7', '8']
  #     current_c_ind = c.index(current_column)
  #     current_r_ind = r.index(current_row)
  #     transformations = []
  #     transformations << "#{c[current_c_ind - 2]}#{r[current_r_ind - 1]}" unless (current_c_ind - 2 < 0) || (current_r_ind - 1 < 0)
  #     transformations << "#{c[current_c_ind + 2]}#{r[current_r_ind + 1]}" unless (current_c_ind + 2 > 7) || (current_r_ind + 1 > 7)
  #     transformations << "#{c[current_c_ind - 2]}#{r[current_r_ind + 1]}" unless (current_c_ind - 2 < 0) || (current_r_ind + 1 > 7)
  #     transformations << "#{c[current_c_ind + 2]}#{r[current_r_ind - 1]}" unless (current_c_ind + 2 > 7) || (current_r_ind - 1 < 0)
  #     transformations << "#{c[current_c_ind - 1]}#{r[current_r_ind - 2]}" unless (current_c_ind - 1 < 0) || (current_r_ind - 2 < 0)
  #     transformations << "#{c[current_c_ind + 1]}#{r[current_r_ind + 2]}" unless (current_c_ind + 1 > 7) || (current_r_ind + 2 > 7)
  #     transformations << "#{c[current_c_ind - 1]}#{r[current_r_ind + 2]}" unless (current_c_ind - 1 < 0) || (current_r_ind + 2 > 7)
  #     transformations << "#{c[current_c_ind + 1]}#{r[current_r_ind - 2]}" unless (current_c_ind + 1 > 7) || (current_r_ind - 2 < 0)

  #     @game_board.flatten.each do |other_square|
  #       current_square.knight_moves << other_square if transformations.include?(other_square.coord)
  #     end
  #   end
  # end

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
