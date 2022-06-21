require 'singleton'
require 'byebug'

class Piece
  attr_reader :color, :symbol
  attr_accessor :pos, :has_moved
  def initialize(board, pos, color = nil)
    @board = board
    @pos = pos
    @color = color
    @has_moved = false
  end

  def self.increment_pos(pos, incr)
    x, y = pos
    dx, dy = incr
    [x + dx, y + dy]
  end

  def friendly?(other_piece)
    self.color == other_piece.color
  end

  def move_into_check?(end_pos)
    board_dup = @board.deep_dup
    board_dup.force_move_piece(self.pos, end_pos)
    board_dup.in_check?(self.color)
  end

  def valid_moves
    self.moves.reject { |pos| move_into_check?(pos) }
  end

  def dup_with_new_board(duped_board)
    self.class.new(duped_board, self.pos, self.color)
  end
end
