move_left = function()
  if curr_col > 1 then
    if curr_pos == 3 then
        curr_col = max(curr_col-1, curr.length)
    else
      curr_col = max(curr_col-1, 1)
    end
  end
end

move_right = function()
  if curr_col < cols then
    if curr_pos == 1 then
      curr_col = min(curr_col+1, cols-curr.length+1)
    else
      curr_col = min(curr_col+1, cols)
    end
  end
end

can_rotate = function()
  if curr_pos == 4 then
    return curr_col+curr.length <= cols+1
  elsif curr_pos == 2 then
    return curr_col >= curr.length
  end
  true
end

rotate = function()
  if curr_pos == 4 then 
    curr_pos = 1
  else 
    curr_pos = curr_pos + 1
  end
end

drop_curr = function()
  if curr_pos == 1 then drop_horiz(curr)
  elsif curr_pos == 2 then drop_vert(reverse(curr))
  elsif curr_pos == 3 then drop_horiz(curr, true)
  elsif curr_pos == 4 then drop_vert(curr)
  end
end

drop_vert = function(coll)
  for letter in coll
    board.drop(curr_col, letter.char)
  end
end

drop_horiz = function(coll, invert=false)
  local count = 0
  for letter in coll
    if invert == true then
      board.drop(curr_col-count, letter.char)
    else
      board.drop(curr_col+count, letter.char)
    end
    count = count+1
  end
end


draw_vert = function(coll, invert=false)
  local count = 0

  for letter in coll
    local x_offset = cell_size*cols/2-cell_size/2
    local letter_x = x_offset-cell_size*(cols-curr_col)
    local y_offset = cell_size*count
    local letter_y = curr_y - y_offset
    if invert and count > 0 then
      letter_y = curr_y + y_offset
    end
    letter.draw(letter_x, letter_y)
    count = count + 1
  end  
end

draw_horiz = function(coll, invert=false)
  local count = 0

  for letter in coll
    local x_offset = (cell_size*cols/2-cell_size/2)
    local letter_x = x_offset-cell_size*(cols-curr_col-count)
    if invert and count > 0 then
      letter_x = x_offset-cell_size*(cols-curr_col+count)
      letter.draw(letter_x, curr_y)
    else 
      letter.draw(letter_x, curr_y)
    end
    
    count = count+1
  end
  
end

draw_curr = function()
  if curr_pos == 1 then draw_horiz(curr)
  elsif curr_pos == 2 then draw_vert(curr)
  elsif curr_pos == 3 then draw_horiz(curr, true)
  elsif curr_pos == 4 then draw_vert(curr, true)
  end
end


next_current = function(letters)
  init_col = round(cols/2)
  count = 0
  next = []

  for letter in letters
    next.push(new Letter(letter, cell_size, init_col+count))
    count = count+1
  end
  
  next
end
