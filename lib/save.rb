# frozen_string_literal: true

module Saves
  def save_game
    Dir.mkdir 'output' unless Dir.exist? 'output'
    puts "\nname your save file:"
    name = gets.chomp
    @filename = "#{name}_game.yaml"
    File.open("output/#{@filename}", 'w') { |file| file.write save_to_yaml }
  end

  def save_to_yaml
    YAML.dump(
      'board' => @board,
      'player1' => @player1,
      'player2' => @player2,
      'current_player' => @current_player,
      'other_player' => @other_player,
      'last_move' => @last_move
    )
  end

  def find_saved_file
    show_file_list
    puts "Load which game? or type 'exit'"
    file_number = gets.chomp
    @saved_game = file_list[file_number.to_i - 1] unless file_number == 'exit'
  end

  def show_file_list
    puts '# File Name(s)'
    file_list.each_with_index do |name, index|
      puts "#{index + 1} #{name}"
    end
  end

  def file_list
    files = []
    Dir.entries('output').each do |name|
      files << name if name.match(/(game)/)
    end
    files
  end

  def load_saved_file
    file = YAML.safe_load(File.read("output/#{@saved_game}"),
                          permitted_classes: [Square, Player, Piece, Pawn, Rook,
                                              Knight, Bishop, Queen, King],
                          aliases: true)
    @board = file['board']
    @player1 = file['player1']
    @player2 = file['player2']
    @current_player = file['current_player']
    @other_player = file['other_player']
    @last_move = file['last_move']
  end
end
