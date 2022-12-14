# frozen_string_literal: true

require_relative 'board'
require_relative 'player'
require_relative 'save'
require 'yaml'

class Game
  attr_accessor :board, :current_player, :other_player, :last_move
  attr_reader :player1, :player2

  include Saves

  def initialize
    @board = BoardCreator.new.game_board
    display_board
    game_type
  end

  def game_type
    puts '===================================='
    puts '=======   Welcome to chess   ======='
    puts '=======   ----------------   ======='
    puts '=======   [1] new game       ======='
    puts '=======   [2] load game      ======='
    puts '===================================='
    input = gets.chomp
    new_game if input == '1'
    load_game if input == '2'
  end

  def new_game
    @player1 = Player.new('team_one', 'Player 1')
    @player2 = Player.new('team_two', 'Player 2')
    @current_player = @player1
    @other_player = @player2
    play_game
  end

  def load_game
    find_saved_file
    load_saved_file
    play_game
  end

  def play_game
    game_over = false
    until game_over == true
      update_moves_all_pieces
      if @current_player.all_valid_moves.empty?
        game_over = true
      else
        display_board
        make_move
        display_board
      end
      @other_player = @current_player
      @current_player = @current_player == @player1 ? @player2 : @player1
    end
    puts "\n\nGAME OVER"
    puts "#{@current_player.name} wins!"
  end

  def update_moves_all_pieces
    pieces = get_pieces
    pieces.each { |piece| piece.update_valid_moves(@board.flatten, @other_player) }
    check_checkmate
  end

  def make_move
    puts "#{@other_player.name} moved #{@last_move}" if @last_move
    print "#{@current_player.name}, enter coordinates of a piece to move: (or 'save' to save the current game) "
    piece_coord = gets.chomp.upcase
    if piece_coord == 'SAVE'
      save_game
      Game.new
    end

    piece_coord = gets.chomp.upcase until validate_piece(piece_coord)

    piece = find_square_by_coordinates(piece_coord).piece

    print "#{piece_coord} #{piece.type} can make the following moves: "
    piece.valid_moves.each { |move| print "#{move.coord} " }

    print "\n#{@current_player.name}, enter destination coordinates: "
    destination_coord = gets.chomp.upcase
    destination_coord = gets.chomp.upcase until validate_destination(destination_coord, piece)
    update_last_move(piece, destination_coord)

    # Check for all special moves & update the board
    double_move(piece, destination_coord)
    en_passant(piece, destination_coord)
    castle(piece, destination_coord)
    update_board(piece, destination_coord)
    transform_pawn(piece, destination_coord)
  end

  def validate_piece(coord)
    # Chosen coordinates must be to a valid square that contains a piece that player
    # controls that has valid moves to make
    display_board
    square = find_square_by_coordinates(coord)
    if square.nil? || square.piece.nil?
      print "Invalid coordinates. #{@current_player.name}, choose a valid piece: "
    elsif square.piece.team != @current_player.team
      print "Invalid entry. #{@current_player.name}, enter coordinates of a piece you control: "
    elsif square.piece.valid_moves.empty?
      print "Invalid entry. That piece has no valid moves. #{@current_player.name}, try another: "
    else
      true
    end
  end

  def validate_destination(coord, piece)
    # Only accepts moves that the chosen piece can legally make
    display_board
    destination_square = find_square_by_coordinates(coord)
    if piece.valid_moves.include?(destination_square)
      true
    else
      print 'Invalid entry. Valid moves include: '
      piece.valid_moves.each { |square| print "#{square.coord} " }
      print "\n#{@current_player.name}, enter a valid move for #{piece.square.coord} #{piece.type}: "
    end
  end

  def update_last_move(piece, destination_coord)
    @last_move = "#{piece.square.coord} #{piece.type} to #{destination_coord}"
  end

  def update_board(piece, destination_coord)
    destination_square = find_square_by_coordinates(destination_coord)

    # Moves the selected piece to the chosen destination. Updates old and new Squares
    destination_square.piece = piece
    piece.square.piece = nil
    piece.square = destination_square

    piece.total_moves += 1
    @current_player.total_moves += 1
  end

  def double_move(piece, destination_coord)
    # Updates #double_moved, making this piece a target for en passant
    return unless piece.type == 'pawn'

    piece.double_moved = false
    return unless find_square_by_coordinates(destination_coord) == piece.double_move

    piece.double_moved = true
    piece.total_moves_when_double_moved = @current_player.total_moves + 1
  end

  def en_passant(piece, destination_coord)
    # Removes the captured enemy pawn
    return unless piece.type == 'pawn' && piece.en_passant_square &&
                  find_square_by_coordinates(destination_coord) == piece.en_passant_destination

    piece.en_passant_square.piece = nil
    piece.en_passant_square = nil
  end

  def transform_pawn(piece, destination_coord)
    return unless piece.type == 'pawn' && piece.final_row.any?(find_square_by_coordinates(destination_coord))

    puts 'What do you want to transform your pawn into?'
    puts "Queen = 'q' | Bishop = 'b' | Knight = 'k' | Rook = 'r'"
    valid_responses = %w[q b k r]
    response = gets.chomp.downcase
    until valid_responses.include?(response)
      puts 'Invalid entry'
      response = gets.chomp.downcase
    end

    case response
    when 'q'
      piece.square.piece = Queen.new('queen', @current_player.team, piece.square)
    when 'b'
      piece.square.piece = Bishop.new('bishop', @current_player.team, piece.square)
    when 'k'
      piece.square.piece = Knight.new('knight', @current_player.team, piece.square)
    when 'r'
      piece.square.piece = Rook.new('rook', @current_player.team, piece.square)
    end
  end

  def castle(piece, destination_coord)
    # Moves the rook that the king is castling in
    dest_sq = find_square_by_coordinates(destination_coord)
    if piece.type == 'king' && dest_sq == piece.left_castle
      piece.left_rook_destination.piece = piece.left_rook_square.piece
      piece.left_rook_square.piece = nil
      piece.left_rook_destination.piece.square = piece.left_rook_destination
    elsif piece.type == 'king' && dest_sq == piece.right_castle
      piece.right_rook_destination.piece = piece.right_rook_square.piece
      piece.right_rook_square.piece = nil
      piece.right_rook_destination.piece.square = piece.right_rook_destination
    end
  end

  def check_checkmate
    @current_player.all_valid_moves = []
    team_pieces = get_pieces.select { |piece| piece.team == @current_player.team }
    team_pieces.each do |piece|
      # Check if each move would put king in check or can get king out of check.
      new_valid = []
      piece.valid_moves.each do |move|
        # Implement the move just to test it out
        piece.square.piece = nil
        saved_square = piece.square
        saved_piece = move.piece || nil
        move.piece = piece
        piece.square = move

        # Update opposing team moves
        opposing_team_pieces = get_pieces.reject { |p| p.team == @current_player.team }
        opposing_team_pieces.each { |p| p.update_valid_moves(@board.flatten, @other_player) }

        # Determine if the king is now in check
        king = team_pieces.select { |p| p.type == 'king' }.first
        opposing_team_moves = []
        get_pieces.each do |p|
          next if p.team == @current_player.team

          p.valid_moves.each { |m| opposing_team_moves << m }
        end

        # If not, keep the move
        unless opposing_team_moves.include?(king.square)
          new_valid << move
          @current_player.all_valid_moves << move
        end

        # Undo the move now that testing is finished
        move.piece = saved_piece
        saved_square.piece = piece
        piece.square = saved_square
      end

      # Update @valid_moves with only the moves that would protect king from check/checkmate
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

  def display_board
    puts %x(/usr/bin/clear)
    puts '   A  B  C  D  E  F  G  H '
    n = 8
    @board.each do |row|
      display = +''
      row.each do |square|
        if square.piece.nil?
          display << "#{square.styling}   \e[0m"
        else
          display << "#{square.styling} #{square.piece.board_piece} \e[0m"
        end
      end
      puts "#{n} #{display}\e[0m #{n}"
      n -= 1
    end
    puts "   A  B  C  D  E  F  G  H \n\n"
  end
end
