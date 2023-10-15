init = function()
  cols = 7
  rows = 7
  cell_size = 18
  
  board = new Board(rows, cols, cell_size) 
  letter_bag = new Letterbag(100)
  reset = new Button("Reset", -140, 90, 35, 15)

  curr = next_current()
  curr_col = round(cols/2)
  curr_pos = 1
  
end

update = function()
  
  if keyboard.press.LEFT then
    move_left()
    
  elsif keyboard.press.RIGHT then
    move_right()

  elsif keyboard.press.UP then
    if can_rotate() then rotate() end

  elsif keyboard.press.ENTER then
    drop_curr()
    curr = next_current()
    curr_pos = 1
    curr_col = round(cols/2)
  end
  
  if reset.pressed() then
    reset_game()
  end
  
end

draw = function()
  screen.clear(game_bg)
  
  // board.draw(50)
  
  // Letter drawing
  draw_curr()

  // Reset
  reset.draw()
  
end

move_left = function()
  if curr_col > 1 then 
    curr_col = max(curr_col-1, 1)
  end
end

move_right = function()
  local len_mod = 0
  
  if curr_pos == 1 or curr_pos == 3 then
    len_mod = curr.length
  end
  
  if curr_col+len_mod-1 < cols then
      curr_col = min(curr_col+1, cols)
  end  
end

can_rotate = function()
  if curr_pos == 4 then
    return curr_col + curr.length <= cols
  elsif curr_pos == 2 then
    return curr_col - curr.length >= 1
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
  elsif curr_pos == 3 then drop_horiz(reverse(curr))
  elsif curr_pos == 4 then drop_vert(curr)
  end
end

drop_vert = function(coll)
  for letter in coll
    board.drop(curr_col, letter.char)
  end
end

drop_horiz = function(coll)
  local count = 0
    for letter in coll
      board.drop(curr_col+count, letter.char)
      count = count+1
    end
end


draw_vert = function(coll)
  local count = 0
    for letter in coll
      local x_offset = cell_size*cols/2-cell_size/2
      local letter_x = x_offset-cell_size*(cols-curr_col)
      local y_offset = cell_size*count
      local letter_y = 75 - y_offset
      letter.draw(letter_x, letter_y)
      count = count + 1
    end  
end

draw_horiz = function(coll)
  local count = 0
    for letter in coll
      local x_offset = cell_size*cols/2-cell_size/2
      local letter_x = x_offset-cell_size*(cols-curr_col-count)
      letter.draw(letter_x, 75)
      count = count+1
    end
end

draw_curr = function()
  if curr_pos == 1 then draw_horiz(curr)
  elsif curr_pos == 2 then draw_vert(curr)
  elsif curr_pos == 3 then draw_horiz(reverse(curr))
  elsif curr_pos == 4 then draw_vert(reverse(curr))
  end
end

next_current = function()
  init_col = round(cols/2)
  count = 0
  next = []
  
  for letter in letter_bag.next()
    next.push(new Letter(letter, cell_size, init_col+count))
    count = count+1
  end
  
  next
end

reset_game = function()
  board = new Board(rows, cols, cell_size) 
  letter_bag = new Letterbag()
  curr = next_current()
end
