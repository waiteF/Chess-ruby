module SlidingPiece
  DIAG_INCREMENTS = [[-1, -1], [1, 1], [-1, 1], [1, -1]]
  HORIZ_INCREMENTS = [[0, 1], [0, -1]]
  VERT_INCREMENTS = [[1, 0], [-1, 0]]

  def moves
    possible_moves = []
    increments = get_increments

    increments.each do |incr|
      prev_pos = self.pos
      loop do
        new_pos = self.class.increment_pos(prev_pos, incr)
        break unless Board.in_bounds?(new_pos)
        
        piece_in_way = @board[new_pos]
        if !self.friendly?(piece_in_way) && !piece_in_way.is_a?(NullPiece)
          possible_moves << new_pos
          break
        elsif self.friendly?(piece_in_way) && !piece_in_way.is_a?(NullPiece)
          break
        end
        possible_moves << new_pos
        prev_pos = new_pos
      end
    end

    possible_moves
  end

  def get_increments
    increments = []
    increments.concat(DIAG_INCREMENTS) if self.move_dirs.include?(:diagonal)
    increments.concat(HORIZ_INCREMENTS) if self.move_dirs.include?(:horizontal)
    increments.concat(VERT_INCREMENTS) if self.move_dirs.include?(:vertical)
    increments
  end

end
