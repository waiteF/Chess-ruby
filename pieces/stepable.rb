module SteppingPiece
  def moves
    possible_moves = []
    steps = self.get_steps
    check_castling(possible_moves)
    steps.each do |step|
      start_x, start_y = self.pos
      dx, dy = step
      new_pos = [start_x + dx, start_y + dy]
      possible_moves << new_pos
    end

    possible_moves.select do |move|
      Board.in_bounds?(move) && !self.friendly?(@board[move])
    end
  end

  def check_castling(possible_moves)
    if self.is_a?(King) && self.has_moved == false
      if self.color == :white
        if self.pos == [7, 4]
          if @board[[7, 7]].is_a?(Rook) && @board[[7, 7]].has_moved == false
            if @board[[7, 6]].is_a?(NullPiece) && @board[[7, 5]].is_a?(NullPiece)
                possible_moves << [7, 6]
                self.can_castle = true
            end
          end
        end
      elsif self.pos == [0, 4]
        if @board[[0, 0]].is_a?(Rook) && @board[[0, 7]].has_moved == false
          if @board[[0, 6]].is_a?(NullPiece) && @board[[0, 5]].is_a?(NullPiece)
              possible_moves << [0, 6]
              self.can_castle = true
          end
        end
      end
    end
  end
end
