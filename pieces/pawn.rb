require_relative 'piece'
require_relative 'stepable'

class Pawn < Piece

  attr_accessor :en_passantable

  def initialize(board, pos, color = nil)
    @has_moved = false
    @en_passantable = false
    super
  end

  def has_moved
    @has_moved = true
  end

  def check_promotion
    if self.color == :black
      if self.pos[0] == 7
        promote!
      end
    else
      if self.pos[0] == 0
        promote!
      end
    end
  end

  def promote!
    @board[self.pos] = Queen.new(@board, self.pos, self.color)
  end

  def moves
    possible_moves = []
    possible_moves += check_forward_moves
    possible_moves += check_attack_moves

    possible_moves
  end

  def check_forward_moves
    x, y = self.pos
    up_down = self.up_or_down

    possible_forward_moves = []
    first_piece, one_forward = check_one_forward(x, y, up_down)
    possible_forward_moves << one_forward if one_forward
    if @has_moved != true
      two_forward = check_two_forward(x, y, up_down, first_piece)
      possible_forward_moves << two_forward if two_forward
    end
    possible_forward_moves
  end

  def check_one_forward(x, y, up_down)
    one_forward = [x + up_down, y]

    first_piece = @board[one_forward]
    if first_piece.is_a?(NullPiece) && Board.in_bounds?(one_forward)
      return first_piece, one_forward
    end
  end

  def check_two_forward(x, y, up_down, first_piece)
    two_forward = [x + (2 * up_down), y]
    second_piece = @board[two_forward]
    if second_piece.is_a?(NullPiece) && Board.in_bounds?(two_forward) && first_piece.is_a?(NullPiece)
      return two_forward unless @has_moved == true
    end
  end

  def check_attack_moves
    x, y = self.pos
    up_down = self.up_or_down
    possible_attack_moves = []
    left_pos = [x + up_down, y - 1]
    right_pos = [x + up_down, y + 1]
    possible_attack_moves = check_en_passant(possible_attack_moves, up_down, x, y)
    [left_pos, right_pos].each do |pos|
      other_piece = @board[pos]
      unless !Board.in_bounds?(pos) || other_piece.is_a?(NullPiece) || self.friendly?(other_piece)
        possible_attack_moves << pos
      end
    end

    possible_attack_moves
  end

  def check_en_passant(possible_attack_moves, up_down, x, y)
    enemy_left_pos = [x, y - 1]
    enemy_right_pos = [x, y + 1]
    [enemy_left_pos, enemy_right_pos].each do |pos|
      other_piece = @board[pos]
      unless !Board.in_bounds?(pos) ||
              !other_piece.is_a?(Pawn) ||
              self.friendly?(other_piece) ||
              !other_piece.en_passantable
        pos[0] += up_down
        possible_attack_moves << pos
      end
    end
    possible_attack_moves
  end

  def up_or_down
    self.color == :black ? 1 : -1
  end

  def to_s
    "♟".colorize(self.color)
  end

end
