class Player
  attr_reader :team, :player
  attr_accessor :all_valid_moves

  def initialize(team, player)
    @team = team
    @player = player
    @all_valid_moves = []
  end
end
