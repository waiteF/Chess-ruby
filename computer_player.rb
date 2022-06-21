require_relative 'pieces'
require_relative 'game.rb'

class ComputerPlayer
  attr_reader :name

  def initialize(board, display, color, name, game)
    @board = board
    @display = display
    @color = color
    @name = name
    @game = game
  end

  def play_turn
    loop do
      handle_rendering
      sleep(0.50)
      forfeit = "forfeit"
      tries = 0
      while forfeit == "forfeit" && tries < 10
        tries += 1
        forfeit = @board.computer_move_piece(@color)
      end
      if forfeit
        @board.any_valid_move(@color)
      end
      break
    end
  end

  private

  def handle_rendering
    system("clear")
    @display.render
    puts "#{@name}'s turn! (#{@color.to_s})"
  end

end
