require_relative 'display.rb'
require_relative 'human_player.rb'
require_relative 'computer_player.rb'
class Game

  def initialize(board)
    @board = board
    @display = Display.new(@board, false)
    @player1 = HumanPlayer.new(board, @display, :white, "Player 1")
    @player2 = HumanPlayer.new(board, @display, :black, "Player 2")
    @currentplayer = @player1
  end

  def setup
    reply = ""
    possible_answers = ["0", "1", "2", "quit", "q", "exit"]
    until possible_answers.include?(reply)
      system("clear")
      puts "How many players? (0/1/2/q)"
      reply = gets.chomp
    end

    if reply == "0"
      @display = Display.new(@board, true)
      @player1 = ComputerPlayer.new(@board, @display, :white, "Player 1", self)
      @currentplayer = @player1
      @player2 = ComputerPlayer.new(@board, @display, :black, "Player 2", self)
    elsif reply == "1"
      @player2 = ComputerPlayer.new(@board, @display, :black, "Player 2", self)
    elsif reply == "q" || reply == "quit" || reply == "exit"
      Process.exit(0)
    end
  end

  def run
    setup

    until over?
      take_turn
      switch_players!
    end

    winner
  end

  def winner
    switch_players!
    system("clear")
    @display.render
    if @board.piece_count < 3
      puts "The game was a draw!"
    else
      puts "#{@currentplayer.name} has won!"
    end
    Process.exit(0)
  end

  private

  def take_turn
    @currentplayer.play_turn
  rescue InvalidMoveError
    retry
  end

  def switch_players!
    @currentplayer = (@currentplayer == @player1 ? @player2 : @player1)
    nil
  end

  def over?
    if @board.checkmate?(:white) || @board.checkmate?(:black)
      return true
    elsif @board.piece_count < 3
      return true
    end
    false
  end

end
