load 'pieces/piece.rb'
load 'board.rb'
load 'display.rb'
load 'cursor.rb'
load 'game.rb'
load 'human_player.rb'

b = Board.new
g = Game.new(b)
g.run
