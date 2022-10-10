class Player
  attr_reader :team, :player, :name
  attr_accessor :all_valid_moves

  def initialize(team, player)
    @team = team
    @player = player
    puts "#{@player}, enter your name:"
    @name = gets.chomp
    @all_valid_moves = []
  end
end
