require_relative 'piece'
require_relative 'slideable'

class Queen < Piece
  include SlidingPiece

  def move_dirs
    [:diagonal, :horizontal, :vertical]
  end

  def to_s
    "♛".colorize(self.color)
  end

end
