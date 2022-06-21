require 'byebug'
require_relative 'pieces'

class ChessError < StandardError; end
class PieceNotFoundError < ChessError; end
class InvalidMoveError < ChessError; end

POINT_VALUES ||= {
  NullPiece: 0,
  Pawn: 1,
  Knight: 3,
  Bishop: 3,
  Rook: 5,
  Queen: 9,
  King: 99
}

class Board

  def initialize
    nil_row = Array.new(8) { NullPiece.instance }
    @grid = [
      self.make_special_row(:black),
      self.make_pawn_row(:black),
      nil_row.dup,
      nil_row.dup,
      nil_row.dup,
      nil_row.dup,
      self.make_pawn_row(:white),
      self.make_special_row(:white)
    ]
  end

  def move_piece(start_pos, end_pos)
    piece_to_move = self[start_pos]
    if piece_to_move.is_a?(NullPiece)
      raise PieceNotFoundError
    elsif !piece_to_move.valid_moves.include?(end_pos)
      raise InvalidMoveError
    end
    piece_to_move.pos = end_pos
    self.castling_actions(start_pos, end_pos, piece_to_move)
    if piece_to_move.is_a?(King) || piece_to_move.is_a?(Rook)
      piece_to_move.has_moved = true
    end
    self[end_pos] = piece_to_move
    self[start_pos] = NullPiece.instance
    pawn_actions(piece_to_move, start_pos, end_pos)
  end

  def castling_actions(start_pos, end_pos, piece_to_move)
    if self[start_pos].color == :white && start_pos == [7, 4]
      if end_pos == [7, 6] && piece_to_move.is_a?(King) && piece_to_move.can_castle
        self.force_move_piece([7, 7], [7, 5])
      end
    elsif start_pos == [0, 4]
      if end_pos == [0, 6] && piece_to_move.is_a?(King) && piece_to_move.can_castle
        self.force_move_piece([0, 7], [0, 5])
      end
    end
  end

  def force_move_piece(start_pos, end_pos)
    piece_to_move = self[start_pos]
    piece_to_move.pos = end_pos
    self[end_pos] = piece_to_move
    self[start_pos] = NullPiece.instance
    pawn_actions(piece_to_move, start_pos, end_pos)
  end

  def deep_dup
    board_dup = Board.new
    dup_grid = @grid.map do |row|
      row.map do |piece|
        piece.dup_with_new_board(board_dup)
      end
    end
    board_dup.grid = dup_grid
    board_dup
  end

  def computer_move_piece(color)
    valid_pieces = get_valid_computer_move_pieces(color)
    piece_with_best_move = get_best_move(valid_pieces, color)
    piece_to_move = piece_with_best_move[1] if piece_with_best_move
    return "forfeit" unless piece_to_move
    start_pos = piece_to_move.pos
    end_pos = piece_with_best_move[2]
    piece_to_move.pos = end_pos
    self.castling_actions(start_pos, end_pos, piece_to_move)
    if piece_to_move.is_a?(King) || piece_to_move.is_a?(Rook)
      piece_to_move.has_moved = true
    end
    self[end_pos] = piece_to_move
    self[start_pos] = NullPiece.instance

    pawn_actions(piece_to_move, start_pos, end_pos)
    nil
  end

  def any_valid_move(color)
    valid_pieces = get_valid_computer_move_pieces(color)
    piece_to_move = valid_pieces.sample
    return unless piece_to_move
    start_pos = piece_to_move.pos
    end_pos = piece_to_move.valid_moves.sample

    piece_to_move.pos = end_pos
    self[end_pos] = piece_to_move
    self[start_pos] = NullPiece.instance
    pawn_actions(piece_to_move)
    nil
  end

  def get_valid_computer_move_pieces(color)
    valid_pieces = []
    @grid.each do |row|
      valid_pieces << row.select do |piece|
        piece.color == color && piece.valid_moves.length > 0
      end
    end
    valid_pieces.flatten!
  end

  def get_best_move(valid_pieces, color)
    all_best_point_values = get_best_point_values(valid_pieces, color)
    best_moves = [[-1, nil, nil]]
    all_best_point_values.each do |piece_best_moves|
      piece_best_moves.each do |best_move|
        best_moves.push(best_move) if best_move[0] >= best_moves.last[0]
      end
    end
    best_moves.reject!{ |move| move[0] < best_moves.last[0] }
    return best_moves.sample
  end

  def get_best_point_values(valid_pieces, color)
    all_best_point_values = []
    valid_pieces.each do |piece|
      point_values = []
      piece.valid_moves.each do |move_pos|
        point_values << [POINT_VALUES[self[move_pos].class.name.to_sym], piece, move_pos]
      end
      piece_best_point_values = filter_best_point_values(point_values, color)
      all_best_point_values << piece_best_point_values
    end
    all_best_point_values
  end

  def filter_best_point_values(point_values, color)
    piece_best_point_values = [[-1, nil, nil]]
    point_values.each do |pv|
      filter_result = filter_by_enemy_moves(pv, color)
      pv[0] += 100 if filter_result == 100
      if !filter_result.nil?
        if pv[0] >= piece_best_point_values.last[0]
          pv[0] += [0, 1].sample if filter_result == 2
          piece_best_point_values.push(pv)
        end
      end
    end
    piece_best_point_values
  end

  def filter_by_enemy_moves(move, color)
    return nil unless move[1]
    board_dup = self.deep_dup
    board_dup.force_move_piece(move[1].pos, move[2])
    enemy_moves = get_enemy_moves(board_dup, color)
    self_value = POINT_VALUES[move[1].class.name.to_sym]
    other_color = (color == :white ? :black : :white)
    return 100 if board_dup.checkmate?(other_color)
    if enemy_moves.include?(move[2]) && self_value > move[0]
      return nil
    else
      return 2 if board_dup.in_check?(other_color)
      return 1
    end
  end

  def [](pos)
    x, y = pos
    @grid[x][y] unless @grid[x].nil?
  end

  def []=(pos, value)
    x, y = pos
    @grid[x][y] = value
  end

  def piece_count
    @grid.flatten.reject!{|piece| piece.class.name == "NullPiece"}.count
  end

  def self.in_bounds?(pos)
    x, y = pos
    x.between?(0, 7) && y.between?(0, 7)
  end

  def in_check?(color)
    king_pos = find_king(color)
    enemy_moves = get_enemy_moves(color)
    enemy_moves.include?(king_pos)
  end

  def checkmate?(color)
    return false unless in_check?(color)
    moves = []

    @grid.each do |row|
      row.each do |piece|
        if piece.color == color
         moves.concat(piece.valid_moves)
        end
      end
    end

    moves.empty?
  end

  private

  def find_king(color)
    kings = []
    @grid.each do |row|
      row.each do |piece|
        kings << piece if piece.is_a?(King)
      end
    end
    foundKing = kings.select { |king| king.color == color }.first
    return foundKing.pos if foundKing
    [-1, -1]
  end

  def get_enemy_moves(board = self, color)
    enemy_moves = []
    board.grid.each do |row|
      row.each do |piece|
        if piece.color != color
          enemy_moves.concat(piece.moves)
        end
      end
    end
    return enemy_moves
  end

  protected

  attr_accessor :grid

  def pawn_actions(piece, start_pos, end_pos)
    if piece.is_a?(Pawn)
      piece.en_passantable = false
      destroy_if_en_passant(start_pos, piece)
      if (start_pos[0] - end_pos[0]).abs > 1
        piece.en_passantable = true
      end
      piece.has_moved
      piece.check_promotion
    end
  end

  def destroy_if_en_passant(start_pos, piece)
    x, y = start_pos
    enemy_left_pos = [x, y - 1]
    enemy_right_pos = [x, y + 1]
    [enemy_left_pos, enemy_right_pos].each do |pos|
      other_piece = self[pos]
      unless !Board.in_bounds?(pos) ||
              !other_piece.is_a?(Pawn) ||
              piece.friendly?(other_piece) ||
              !other_piece.en_passantable
        self[pos] = NullPiece.instance
      end
    end
  end

  def make_special_row(color)
    top_bot = color == :black ? 0 : 7
    [
      Rook.new(self, [top_bot, 0], color),
      Knight.new(self, [top_bot, 1], color),
      Bishop.new(self, [top_bot, 2], color),
      Queen.new(self, [top_bot, 3], color),
      King.new(self, [top_bot, 4], color),
      Bishop.new(self, [top_bot, 5], color),
      Knight.new(self, [top_bot, 6], color),
      Rook.new(self, [top_bot, 7], color)
    ]
  end


  def make_pawn_row(color)
    top_bot = color == :black ? 1 : 6
    [
      Pawn.new(self, [top_bot, 0], color),
      Pawn.new(self, [top_bot, 1], color),
      Pawn.new(self, [top_bot, 2], color),
      Pawn.new(self, [top_bot, 3], color),
      Pawn.new(self, [top_bot, 4], color),
      Pawn.new(self, [top_bot, 5], color),
      Pawn.new(self, [top_bot, 6], color),
      Pawn.new(self, [top_bot, 7], color)
    ]
  end

end
