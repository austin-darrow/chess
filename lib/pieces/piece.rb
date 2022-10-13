# frozen_string_literal: true

class Piece
  attr_reader :type, :team, :board_piece
  attr_accessor :square, :total_moves, :valid_moves

  C = %w[A B C D E F G H].freeze

  def initialize(type, team, square)
    @type = type
    @team = team
    @square = square
    @total_moves = 0
    @valid_moves = []
  end

  def find(coord, squares)
    squares.select { |sq| sq.coord == coord }.first
  end

  # Removes any squares beyond the first square containing a piece. Keeps that
  # square if it's an enemy piece; omits if its the same team.
  def remove_jumps(full_array, sort = nil)
    case sort
    when 'positive'
      full_array.sort! { |a, b| a.coord <=> b.coord }
    when 'negative'
      full_array.sort! { |a, b| b.coord <=> a.coord }
    end

    valid_arr = full_array.take_while { |sq| sq.piece.nil? }
    full_array -= valid_arr
    valid_arr << full_array.first
  end

  def add_cardinal_squares(all_squares)
    u, d, l, r = [], [], [], []
    all_squares.each do |other_square|
      if @square.row == other_square.row
        if @square.column > other_square.column
          l << other_square
        elsif @square.column < other_square.column
          r << other_square
        end
      end
      if @square.column == other_square.column
        if @square.row > other_square.row
          d << other_square
        elsif @square.row < other_square.row
          u << other_square
        end
      end
    end
    [u, d, l, r]
  end

  def add_diagonal_squares(all_squares)
    lu, ld, ru, rd = [], [], [], []
    for i in 1..7 do
      x = C.index(@square.column)
      y = @square.row
      lu << find("#{C[x - i]}#{y + i}", all_squares) if (x - i > -1) && (y + i < 9)
      ld << find("#{C[x - i]}#{y - i}", all_squares) if (x - i > -1) && (y - i > 0)
      ru << find("#{C[x + i]}#{y + i}", all_squares) if (x + i < 8) && (y + i < 9)
      rd << find("#{C[x + i]}#{y - i}", all_squares) if (x + i < 8) && (y - i > 0)
    end
    [lu, ld, ru, rd]
  end

  # Flatten, remove nils, and remove pieces of the same team
  def clean_valid_moves(*unclean)
    valid = [unclean].flatten.compact
    valid.select! { |sq| sq.piece ? sq.piece.team != @team : sq }
    valid.flatten.compact
    valid
  end
end
