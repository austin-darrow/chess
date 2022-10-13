# frozen_string_literal: true

class Player
  attr_reader :team, :player, :name
  attr_accessor :all_valid_moves, :total_moves

  def initialize(team, player)
    @team = team
    @player = player
    puts "#{@player}, enter your name:"
    @name = gets.chomp
    @all_valid_moves = []
    @total_moves = 0
  end
end
