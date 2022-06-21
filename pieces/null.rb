require_relative 'piece'

class NullPiece < Piece
  include Singleton

  def initialize
    @color = nil
    @symbol = nil
  end

  def to_s
    " "
  end

  def moves
    []
  end

  def dup_with_new_board(duped_board)
    NullPiece.instance
  end

end
