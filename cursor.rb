require "io/console"
require_relative 'display.rb'

KEYMAP ||= {
  " " => :space,
  "h" => :left,
  "j" => :down,
  "k" => :up,
  "l" => :right,
  "w" => :up,
  "a" => :left,
  "s" => :down,
  "d" => :right,
  "\t" => :tab,
  "\r" => :return,
  "\n" => :newline,
  "\e" => :escape,
  "\e[A" => :up,
  "\e[B" => :down,
  "\e[C" => :right,
  "\e[D" => :left,
  "\177" => :backspace,
  "\004" => :delete,
  "\u0003" => :ctrl_c,
}

MOVES ||= {
  left: [0, -1],
  right: [0, 1],
  up: [-1, 0],
  down: [1, 0]
}

class Cursor

  attr_reader :cursor_pos, :board
  attr_accessor :selected

  def initialize(cursor_pos, board, display)
    @cursor_pos = cursor_pos
    @board = board
    @selected = false
    @display = display
  end

  def get_input
    key = KEYMAP[read_char]
    handle_key(key)
  end

  private

  def read_char
    STDIN.echo = false
    STDIN.raw!
    input = STDIN.getc.chr

    if input == "\e" then
      input << STDIN.read_nonblock(3) rescue nil
      input << STDIN.read_nonblock(2) rescue nil
    end

    STDIN.echo = true
    STDIN.cooked!

    return input
  end

  def handle_key(key)
    case key
    when :return, :space
      unless @board[cursor_pos].is_a?(NullPiece) && !@selected
        toggle_selected
        return self.cursor_pos
      end
      nil
    when :left, :right, :up, :down
      update_pos(MOVES[key])
      nil
    when :escape
      Process.exit(0)
      nil
    end
  end

  def toggle_selected
    @selected = !@selected
    @display.stored_moves = nil
  end

  def update_pos(diff)
    start_x, start_y = @cursor_pos
    dx, dy = diff
    @cursor_pos = [start_x + dx, start_y + dy]
    unless Board.in_bounds?(@cursor_pos)
      @cursor_pos = [start_x, start_y]
    end
  end
end
