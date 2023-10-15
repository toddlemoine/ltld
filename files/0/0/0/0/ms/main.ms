init = function()
  cols = 7
  rows = 7
  cell_size = 18
  
  board = new Board(rows, cols, cell_size) 
  letter_bag = new Letterbag(100)
  reset = new Button("Reset", -140, 90, 35, 15)

  curr = next_current()
  
end

update = function()
  
  if keyboard.press.LEFT then
    if curr[0].col > 1 then 
      for letter in curr
        letter.col = max(letter.col-1, 1)
      end
    end
    
  elsif keyboard.press.RIGHT then
    if curr[curr.length-1].col < cols then
      for letter in curr
        letter.col = min(letter.col+1, cols)
      end
    end
    
  elsif keyboard.press.ENTER then
    for letter in curr
      board.drop(letter.col, letter.char)
    end
    curr = next_current()
  end
  
  if reset.pressed() then
    reset_game()
  end
  
end

draw = function()
  screen.clear(game_bg)
  
  board.draw(50)
  
  for letter in curr
    local x_offset = cell_size*cols/2-cell_size/2
    local letter_x = x_offset-cell_size*(cols-letter.col)
    letter.draw(letter_x, 75)
  end

  // Reset
  reset.draw()
  
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
