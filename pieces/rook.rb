require_relative 'piece'
require_relative 'slideable'

class Rook < Piece
  include SlidingPiece
  attr_accessor :has_moved

  def move_dirs
    [:horizontal, :vertical]
  end

  def to_s
    "♜".colorize(self.color)
  end

end
