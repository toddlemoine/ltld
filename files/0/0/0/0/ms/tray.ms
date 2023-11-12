Tray = class
  piece_pos = []
  x = null
  y = null
  
  constructor = function(x, offset)
    this.x = x
    this.y = -(screen.height/2)+offset
    this.offset = offset
  end
  
  draw_selection = function(start_x, start_y, end_x, end_y)
    for i = 0 to 2
      screen.drawLine(start_x, start_y+i, end_x, end_y+i, red)  
    end
  end
  
  draw = function(pieces)
    local total_chars = 0
    local piece_pos = []
    
    for piece in pieces
      total_chars += piece.length
    end

    local half_cell = cell_size/2
    local pieces_width = (total_chars+pieces.length-1)*cell_size
    local x = -pieces_width/2 + (half_cell*pieces.length)/2
    
    // Do the layout
    for piece in pieces
      pos = object
        x1 = x
        x2 = 0
      end

      local char_count = 0

      // ******************
      // Specials
      // ******************
      for char in piece
        if char == "@" then
          new BombSpecial(x, y).draw()
        elsif char == "<" then
          new BumpLeftSpecial(x, y).draw()
        elsif char == ">" then
          new BumpRightSpecial(x, y).draw()
        else
          new Letter(char, cell_size, x, y).draw()
        end
        
        x += cell_size
      end
      
      pos.x2 = x
      piece_pos.push(pos)

      // Draw selection
      if selected_piece == piece_pos.length-1 then
        line_y = -offset+cell_size/2.5
        line_x1 = pos.x1-half_cell
        line_x2 = pos.x2-half_cell
        draw_selection(line_x1, line_y, line_x2, line_y)
      end
      
      // Add space between pieces
      x += cell_size/2
    end
  end  
  
end


piece_move_left = function()
  selected_piece = max(selected_piece-1, 0)
end

piece_move_right = function()
  selected_piece = min(selected_piece+1, max_player_pieces-1)
end