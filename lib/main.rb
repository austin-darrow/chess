require_relative 'board'
require_relative 'player'
require_relative 'game'

test = Game.new
test.display_board
puts "---"

pieceA8 = test.board.flatten.first.piece
test.update_moves_all_pieces
if pieceA8.valid_moves.empty?
  puts "empty"
else
  puts pieceA8.valid_moves
end

c4 = test.find_square_by_coordinates("C4")
c4.piece = Rook.new('rook', 'team_one', c4)
f4 = test.find_square_by_coordinates("F4")
f4.piece = Pawn.new('pawn', 'team_two', f4)
f3 = test.find_square_by_coordinates("F3")
f3.piece = Pawn.new('pawn', 'team_two', f3)
e5 = test.find_square_by_coordinates("E5")
e5.piece = Knight.new('knight', 'team_two', e5)
f2 = test.find_square_by_coordinates("F2")
e2 = test.find_square_by_coordinates("E2")
d4 = test.find_square_by_coordinates("D4")
d4.piece = Bishop.new('bishop', 'team_one', d4)
d6 = test.find_square_by_coordinates("D6")
d6.piece = Queen.new('queen', 'team_two', d6)
d5 = test.find_square_by_coordinates("D5")
d5.piece = King.new('king', 'team_one', d5)
test.display_board

test.update_moves_all_pieces
print 'c4 rook valid moves '
c4.piece.valid_moves.each { |sq| print "#{sq.coord} " }
puts ''
print 'e5 knight valid moves '
e5.piece.valid_moves.each { |sq| print "#{sq.coord} " }
puts ''
print 'f2 pawn valid moves '
f2.piece.valid_moves.each { |sq| print "#{sq.coord} " }
puts ''
print 'e2 pawn valid moves '
e2.piece.valid_moves.each { |sq| print "#{sq.coord} " }
puts ''
print 'f3 pawn valid moves '
f3.piece.valid_moves.each { |sq| print "#{sq.coord} " }
puts ''
print 'd4 bishop valid moves '
d4.piece.valid_moves.each { |sq| print "#{sq.coord} " }
puts ''
print 'd6 queen valid moves '
d6.piece.valid_moves.each { |sq| print "#{sq.coord} " }
puts ''
print 'd5 king valid moves '
d5.piece.valid_moves.each { |sq| print "#{sq.coord} " }
puts ''
