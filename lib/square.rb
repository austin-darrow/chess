# frozen_string_literal: true

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
