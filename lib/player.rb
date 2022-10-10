class Player
  attr_reader :team
  attr_accessor :all_valid_moves

  def initialize(team)
    @team = team
    @all_valid_moves = []
  end
end
