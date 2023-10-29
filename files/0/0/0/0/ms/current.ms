Current = class
  constructor = function(x, y)
    this.x = x
    this.y = y
    this.pos = 1
    this.col = round(cols/2)
    this.cells = []
    this.dropping = false
    this.tick = 60
  end
  
  is_pending = function() cells.length == 0 end
  
  set_pieces = function(letters)
    init_col = round(cols/2)
    count = 0
    cells = []
  
    for letter in letters
      cells.push(new Letter(letter, cell_size, 0, y))
      count += 1
    end
    
    update()
  end  
  
  move_left = function()
    if col > 1 then
      if pos == 3 then
        col = max(col-1, cells.length)
      else
        col = max(col-1, 1)
      end
    end
  end
  
  move_right = function()
    if col < cols then
      if pos == 1 then
        col = min(col+1, cols-cells.length+1)
      else
        col = min(col+1, cols)
      end
    end
  end
  
  can_rotate = function()
    if pos == 4 then
      return col+cells.length <= cols+1
    elsif pos == 2 then
      return col >= cells.length
    end
    true
  end
  
  rotate = function()
    if not can_rotate() then return end
    
    if pos == 4 then 
      pos = 1
    else 
      pos += 1
    end
  end
  
  drop = function()
    dropping = true
    if pos == 1 then drop_horiz(cells)
    elsif pos == 2 then drop_vert(reverse(cells))
    elsif pos == 3 then drop_horiz(cells, true)
    elsif pos == 4 then drop_vert(cells)
    end
  end
  
  draw_piece = function()
    if pos == 1 then draw_horiz(cells)
    elsif pos == 2 then draw_vert(cells)
    elsif pos == 3 then draw_horiz(cells, true)
    elsif pos == 4 then draw_vert(cells, true)
    end
  end
  
  // draw_special = function() 
  //   local x_offset = (cell_size*cols/2-cell_size/2)
  //   local special_x = x_offset-cell_size*(cols-col-count)
  //   new Special(special_chooser.value, special_x, y).draw()
  // end
    
  drop_vert = function(coll)
    for letter in coll
      // board.drop(col, letter.char)
    end
  end
  
  drop_horiz = function(coll, invert=false)
    local count = 0
    for letter in coll
      if invert == true then
        letter.target = board.drop_target_for(col-count, letter.char)
      else
        letter.target = board.drop_target_for(col+count, letter.char)
      end
      count += 1
    end
  end

  
  draw_vert = function(coll, invert=false)
    local count = 0
  
    for letter in coll
      local x_offset = cell_size*cols/2-cell_size/2
      local letter_x = x_offset-cell_size*(cols-col)
      local y_offset = cell_size*count
      local letter_y = y - y_offset
      if invert and count > 0 then
        letter_y = y + y_offset
      end
      letter.draw(letter_x, letter_y)
      count += 1
    end  
  end
  
  update_horiz = function(coll, invert=false)
    local count = 0
  
    for letter in coll
      if letter.at_target() then continue end
      
      local x_offset = (cell_size*cols/2-cell_size/2)
      local letter_x = x_offset-cell_size*(cols-col-count)

      if invert and count > 0 then
        letter_x = x_offset-cell_size*(cols-col+count)
      end
      
      letter.set_xy(letter_x, y)
      count += 1
    end    
  end
  
  draw_horiz = function(coll, invert=false)
    local count = 0
  
    for letter in coll
      if letter.at_target() then continue end
      
      local x_offset = (cell_size*cols/2-cell_size/2)
      local letter_x = x_offset-cell_size*(cols-col-count)

      if invert and count > 0 then
        letter_x = x_offset-cell_size*(cols-col+count)
      end
      
      letter.draw()
      count += 1
    end
  end
  
  stop_dropping = function()
    drop_to = null  
  end
  
  update = function()
    if dropping == true then
      y -= 1
      tick -= 2
    end
    
    if pos == 1 then update_horiz(cells)
      elsif pos == 2 then update_vert(cells)
      elsif pos == 3 then update_horiz(cells, true)
      elsif pos == 4 then update_vert(cells, true)
      end      
    
    if dropping then
      dropping = all(cells, function(cell) cell.at_target() == false end)
    end
  
  end
  
  draw = function()
    for cell in cells 
      cell.draw()
    end
  end
end

