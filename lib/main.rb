require_relative 'board'
require_relative 'player'
require_relative 'game'

test = Game.new
test.display_board
# test.update_pawn_moves
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
b4 = test.find_square_by_coordinates("B4")
b4.piece = Pawn.new('pawn', 'team_one', b4)
e5 = test.find_square_by_coordinates("E5")
e5.piece = Knight.new('knight', 'team_two', e5)
f2 = test.find_square_by_coordinates("F2")
e2 = test.find_square_by_coordinates("E2")
test.display_board

test.update_moves_all_pieces
print 'c4 rook valid moves '
c4.piece.valid_moves.each { |sq| print "#{sq.coord} " }
puts ''
print 'e5 knight valid moves '
e5.piece.valid_moves.each { |sq| print "#{sq.coord} " }
puts ''
print 'b4 pawn valid moves '
b4.piece.valid_moves.each { |sq| print "#{sq.coord} " }
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
