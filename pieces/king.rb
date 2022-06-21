require_relative 'piece'
require_relative 'stepable'

class King < Piece
  attr_accessor :can_castle
  include SteppingPiece

  def initialize(board, pos, color = nil)
    super(board, pos, color)
    @can_castle = false
  end

  def get_steps
    [
      [-1, -1],
      [-1, 0],
      [-1, 1],
      [0, -1],
      [0, 1],
      [1, -1],
      [1, 0],
      [1, 1]
    ]
  end

  def to_s
    "♚".colorize(self.color)
  end

end
