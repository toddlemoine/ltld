Current = class
  constructor = function(x, y)
    this.x = x
    this.y = y
    this.pos = 1
    this.col = round(cols/2)
    this.cells = []
    this.dropping = false
    this.tick = 60
    this.done = false
    this.allow_rotate = true
  end
  
  is_pending = function() cells.length == 0 end
  
  set_pieces = function(letters)
    cells = []
    
    for letter in letters
      if letter == "@" then 
        cells.push(new BombSpecial(0, y))
        allow_rotate = false
      elsif letter == "<" then 
        cells.push(new BumpLeftSpecial(0, y))
        allow_rotate = false
      elsif letter == ">" then 
        cells.push(new BumpRightSpecial(0, y))
        allow_rotate = false
      else
        cells.push(new Letter(letter, cell_size, 0, y))
        allow_rotate = true
      end
    end
    
    // layout the new cells
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
  
  can_rotate_ccw = function()
    if pos == 4 then
      return col >= cells.length
    elsif pos == 2 then
      return col+cells.length <= cols+1
    end
    true
  end  
  
  rotate_ccw = function()
    if not can_rotate_ccw() then return end
    
    if pos == 1 then 
      pos = 4
    else 
      pos -= 1
    end    
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
    if any(cells, function(cell) cell.enabled end) then
      dropping = true
      if pos == 1 then drop_horiz(cells)
      elsif pos == 2 then drop_vert(reverse(cells))
      elsif pos == 3 then drop_horiz(cells, true)
      elsif pos == 4 then drop_vert(cells)
      end
    else
      debug("cannot drop")
    end
  end
  
  drop_vert = function(coll)
    for letter in coll
      if letter.special then
        letter.target = board.drop_target_for_special(col+count)
      else
        letter.target = board.drop_target_for(col, letter.char)
      end
    end
  end
  
  drop_horiz = function(coll, invert=false)
    local count = 0
    for letter in coll
      if invert then
        letter.target = board.drop_target_for(col-count, letter.char)
      else
        if letter.special then
          letter.target = board.drop_target_for_special(col+count)
        else
          letter.target = board.drop_target_for(col+count, letter.char)
        end
      end
      count += 1
    end
  end
  
  update_vert = function(coll, invert=false)
    
    local count = 0
  
    for letter in coll
      if not dropping then
        local x_offset = cell_size*cols/2-cell_size/2
        local y_offset = cell_size*count
        letter.x = x_offset-cell_size*(cols-col)
        letter.y = y - y_offset
        
        if not letter.special then
          letter.enabled = board.column_is_open(col-1)
        else
          letter.set_enabled(col-1)
        end
                
        if invert and count > 0 then
          letter.y = y + y_offset
        end
        
      end
      
      letter.update()
      count += 1
    end  
  end
  
  update_horiz = function(coll, invert=false)
    local count = 0
  
    for letter in coll
      if not dropping then
        local x_offset = (cell_size*cols/2-cell_size/2)

        letter.x = x_offset-cell_size*(cols-col-count)
        letter.y = y
        
        if not letter.special then
          letter.enabled = board.column_is_open(col-1)
        end
                
        if invert then
          if count > 0 then
            letter.x = x_offset-cell_size*(cols-col+count)
            letter.enabled = board.column_is_open(col-count-1)
          end
        else
          if count > 0 then
            letter.enabled = board.column_is_open(col+count-1)
          end
        end
      end
      
      letter.update()
      count += 1
    end    
  end
  
  update = function()
    if pos == 1 then update_horiz(cells)
      elsif pos == 2 then update_vert(cells)
      elsif pos == 3 then update_horiz(cells, true)
      elsif pos == 4 then update_vert(cells, true)
      end      
    
    if dropping then
      all_done = all(cells, function(cell) cell.done() end)
      
      if all_done then 
        cells = [] 
        dropping = false
        done = true
      end
      
    end
  end
  
  draw = function()
    for cell in cells 
      cell.draw()
    end
  end
end

