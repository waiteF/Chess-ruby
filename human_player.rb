class HumanPlayer
  attr_reader :name

  def initialize(board, display, color, name)
    @board = board
    @cursor = display.cursor
    @stored_pos = nil
    @display = display
    @color = color
    @name = name
  end

  def play_turn
    loop do
      handle_rendering
      selected_pos = @cursor.get_input
      next if selected_pos.nil?

      if @cursor.selected == false
        @board.move_piece(@stored_pos, selected_pos)
        @display.selected_pos = nil
        break
      else
        handle_selected_cursor(selected_pos)
      end
    end
  end

  private

  def handle_rendering
    system("clear")
    @display.render
    puts "#{@name}'s turn! (#{@color.to_s})"
  end

  def handle_selected_cursor(selected_pos)
    if @board[selected_pos].color == @color
      @stored_pos = selected_pos
      @display.selected_pos = selected_pos
    else
      @cursor.selected = false
    end
  end

end
