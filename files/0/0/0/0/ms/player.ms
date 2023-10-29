Player = class
  score = 0
  pieces = []
  piece_pos = []
  words = []
  avail_specials = 2
  
  constructor = function()
    this.fill()
  end
  
  add_points = function(points)
    score += points  
  end
  
  fill = function() 
    for i = 1 to max_player_pieces-pieces.length
      pieces.push(letter_bag.next())
    end
  end
  
  select = function(at)
    piece = pieces.removeAt(at)
    fill()
    piece
  end
  
  draw_pieces = function()
    local total_chars = 0
    piece_pos = []
    
    for piece in pieces
      total_chars += piece.length
    end

    local half_cell = cell_size/2
    local pieces_width = (total_chars+pieces.length-1)*cell_size
    local x = -pieces_width/2 + half_cell

    for piece in pieces
      pos = object
        x1 = x
        x2 = 0
      end
      
      for char in piece
        new Letter(char, cell_size, x, piece_y).draw()
        x += cell_size
      end
      
      pos.x2 = x
      piece_pos.push(pos)
      
      // Draw selection
      if selected_piece == piece_pos.length-1 then
        line_y = piece_y+half_cell+3
        line_x1 = pos.x1-half_cell
        line_x2 = pos.x2-half_cell
        screen.drawLine(line_x1, line_y, line_x2, line_y, blue)
        screen.drawLine(line_x1, line_y+1, line_x2, line_y+1, blue)
      end
      
      // Add space between pieces
      x += cell_size
    end
  end
end

piece_move_down = function()
  if selected_piece != -1 then
    selected_piece = -1
  end
end

piece_move_up = function()
  if selected_piece == -1 then
    selected_piece = 0
  end
end

piece_move_left = function()
  selected_piece = max(selected_piece-1, 0)
end

piece_move_right = function()
  selected_piece = min(selected_piece+1, max_player_pieces-1)
end