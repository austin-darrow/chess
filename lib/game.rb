require_relative 'board'
require_relative 'player'

class Game
  attr_accessor :board, :current_player
  attr_reader :player1, :player2

  def initialize
    @board = BoardCreator.new.game_board
    @player1 = Player.new('team_one')
    @player2 = Player.new('team_two')
    @current_player = @player1
  end

  def play_game
    game_over = false
    until game_over == true
      update_moves_all_pieces
      if @current_player.all_valid_moves.empty?
        game_over = true
      else
        # Make a move
        # Check & apply special conditions (pawn transform, en passant)
        display_board
        @current_player == @player1 ? @player2 : @player1
      end
    end
    puts '=========================================='
    puts '===============GAME OVER=================='
    puts '=========================================='
  end

  def protect_king
    # Update valid moves--if you are in check, only keep moves if it would get out of check.
    # If not in check, only keep moves if it wouldn't put you in check.
    @current_player.all_valid_moves = []
    team_pieces = get_pieces.select { |piece| piece.team == @current_player.team }
    team_pieces.each do |piece|
      # Check if each move would put king in check or can get king out of check.
      new_valid = []
      piece.valid_moves.each do |move|
        # Make a test copy of the board, its pieces, this current piece, and the potential move
        board_copy = Marshal.load(Marshal.dump(@board))
        pieces_copy = []
        board_copy.flatten.each do |square|
          next if square.piece.nil?
          pieces_copy << square.piece
        end
        piece_copy = pieces_copy.select { |p| p.square.coord == piece.square.coord }.first
        move_copy = board_copy.flatten.select { |sq| sq.coord == move.coord }.first

        # Implement the move on the fake test board
        move_copy.piece = piece_copy
        piece_copy.square.piece = nil
        piece_copy.square = move_copy

        # Update valid moves with new board state
        pieces_copy.each { |p_copy| p_copy.update_valid_moves(board_copy.flatten) }
        other_team_moves_copy = []
        pieces_copy.each do |p|
          p.valid_moves.each { |m| other_team_moves_copy << m } unless p.team == @current_player.team
        end

        # If king is in check after making the potential move, it's an illegal move. Exclude from @valid_moves
        current_team_king_copy = pieces_copy.select { |piece| piece.type == 'king' }.first
        unless other_team_moves_copy.include?(current_team_king_copy)
          new_valid << move
          @current_player.all_valid_moves << move
        end
      end

      # Finally, update @valid_moves on the real board
      piece.valid_moves = new_valid
    end
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
    pieces.each { |piece| piece.update_valid_moves(@board.flatten) }
    protect_king
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
