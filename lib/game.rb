require_relative 'board'

class Game
  attr_accessor :board

  def initialize
    @board = BoardCreator.new.game_board
  end

  def update_valid_moves
    update_pawn_moves
  end

  def get_pieces
    pieces = []
    @board.flatten.each do |square|
      next if square.piece.nil?
      pieces << square.piece
    end
    pieces
  end

  def find_square_by_coordinates(coord)
    @board.flatten.select { |sq| sq.coord == coord }.first
  end

  def update_moves_all_pieces
    pieces = get_pieces
    # pawns = []
    # rooks = []
    # knights = []
    # queens = []
    # kings = []
    # bishops = []
    pieces.each { |piece| piece.update_valid_moves(@board.flatten) }
    # pieces.each do |piece|
    #   pawns.push(piece) if piece.is_a?(Pawn)
    #   rooks.push(piece) if piece.is_a?(Rook)
    #   knights.push(piece) if piece.is_a?(Knight)
    #   queens.push(piece) if piece.is_a?(Queen)
    #   kings.push(piece) if piece.is_a?(King)
    #   bishops.push(piece) if piece.is_a?(Bishop)
    # end

    # pawns.each(&:update_valid_moves)
    # rooks.each(&:update_valid_moves)
    # knights.each(&:update_valid_moves)
    # queens.each(&:update_valid_moves)
    # kings.each(&:update_valid_moves)
    # bishops.each(&:update_valid_moves)
  end

  # def update_pawn_moves
  #   pieces = get_pieces
  #   pawns = []
  #   pieces.each { |piece| pawns.push(piece) if piece.is_a?(Pawn) }
  #   # puts pawns

  #   pawns.each do |pawn|
  #     current_column = pawn.square.coord.split('').first
  #     current_row = pawn.square.coord.split('').last.to_i
  #     # c = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
  #     # r = ['1', '2', '3', '4', '5', '6', '7', '8']
  #     # current_c_ind = c.index(current_column)
  #     # current_r_ind = r.index(current_row)

  #     if pawn.team == 'team_one'
  #       # Normal move up 1
  #       square_above = find_square_by_coordinates("#{current_column}#{current_row + 1}")
  #       pawn.valid_moves << square_above
  #       # square_above.piece
  #       # square_above
  # #       if pawn.total_moves == 0
  # #         # Double move if first
  # #       end

  # #       # Capture enemy pieces if in diagonals 1 away
  # #       # En passant special move

  # #     elsif pawn.team == 'team_two'
  # #       # Copy team_one but with reverse coordinates
  #     end
  #   end
  # end

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
