require_relative 'piece'
require_relative 'stepable'

class Knight < Piece
  include SteppingPiece
  def get_steps
    [
      [2, 1],
      [2, -1],
      [-2, 1],
      [-2, -1],
      [1, 2],
      [-1, 2],
      [1, -2],
      [-1, -2]
    ]
  end

  def to_s
    "♞".colorize(self.color)
  end

end
