require_relative 'piece'
require_relative 'slideable'

class Bishop < Piece
  include SlidingPiece

  def move_dirs
    [:diagonal]
  end

  def to_s
    "♝".colorize(self.color)
  end

end
