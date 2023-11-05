init = function()
  DEBUGGER = true
  
  cols = 5
  rows = 7
  cell_size = 20
  game_over = false
  
  flash_words = []
  selected_piece = 0 // selected piece  
  specials_used = 0
  max_player_pieces = 4
  
  // Set up playing area
  dict = new Dictionary()
  board = new Board(rows, cols, cell_size) 
  letter_bag = new Letterbag(cols*rows)
  tray = new Tray(0, 90)
  curr = new Current(0, 140)
  
  // Mobile and mouse controls
  control_move_left = new MoveControl(-screen.width/2+50, -(screen.height/2)+45, true)
  control_move_right = new MoveControl(-screen.width/2+60, -(screen.height/2)+45, false)
  control_rotate = new SelectControl(screen.width/2-75, -(screen.height/2)+30, gray)
  control_select = new SelectControl(screen.width/2-35, -(screen.height/2)+30, red)
  
  // Set up players
  curr_player = 0
  players = [new Player()]

  reset = new Button("Reset", -80, -167, 35, 15)
  
end

update = function()
  if game_over then return end
  
  update_flash_words()

  if curr.is_pending() then
    if controls.left() then
      piece_move_left()
      
    elsif controls.right() then
      piece_move_right()

    elsif controls.select() then
      curr.set_pieces(current_player().select(selected_piece))
    end
    
  else
    
    if not curr.dropping then

      if controls.left() then
        curr.move_left()
        
      elsif controls.right() then
        curr.move_right()
    
      elsif controls.up() then
        curr.rotate()

      elsif controls.down() then
        curr.rotate(true)
        
      elsif controls.select() then
        curr.drop()
      end

    end
    
    curr.update()

    if curr.done then
      current_player().add_results(board.latest_results)
      current_player().remove_results(board.latest_removed_results)
      board.update()
      
      debug("TOTAL WORDS: " + board.words_used())
      debug("PLAYER WORDS: " + current_player().words())
      
      if board.filled() then
        game_over = true
      else
        next_round()  
      end
    end
    
  end
  
  if reset.pressed() then
    reset_game()
  end
  
end

draw = function()
  screen.clear(game_bg)
  screen.setFont(font_board)
  
  if screen.isFontReady(font_board) then  
    board.draw(80)
    
    draw_controls()
    control_move_left.draw()
    control_move_right.draw()
    control_rotate.draw()
    control_select.draw()
    
    // Letter drawing
    curr.draw()
    
    // Tray with pieces
    tray.draw(current_player().pieces)
    
    // Score
    draw_score()
    
    // Flash words
    flash_words.forEach(function(fw, index) 
      fw.draw(index) 
    end)

    // Reset
    // reset.draw()
    
    if game_over then
      draw_game_over()
    end
    
  end
end

controls = object
  left = function() keyboard.press.A or keyboard.press.LEFT or control_move_left.pressed() end
  right = function() keyboard.press.D or keyboard.press.RIGHT or control_move_right.pressed() end
  up = function() keyboard.press.W or keyboard.press.UP or control_rotate.pressed() end
  down = function() keyboard.press.S or keyboard.press.DOWN end
  select = function() keyboard.press.SPACE or keyboard.press.ENTER or control_select.pressed() end
end

current_player = function()
  players[curr_player]  
end

next_round = function()
  board.reset_score()
  curr = new Current(0, 130)
end

reset_game = function()
  board = new Board(rows, cols, cell_size) 
  letter_bag = new Letterbag()
  game_over = false
  next_round()
end

update_flash_words = function()
  local x = 0
  for fw in flash_words
    if fw.done then 
      flash_words.removeElement(fw)
    else
      after x*1.5 seconds do
        fw.update() 
      end
      x += 1
    end
  end
end

draw_score = function()
  screen.drawText("WORDS", -screen.width/2+20, screen.height/2-6, 12, black)
  screen.drawText(current_player().word_count(), -screen.width/2+20, screen.height/2-20, 20, black)
  
  screen.drawText("SCORE", screen.width/2-20, screen.height/2-6, 12, black)
  screen.drawText(current_player().score(), screen.width/2-20, screen.height/2-20, 20, black)
end

draw_game_over = function()
  screen.drawText("Game Over", 2, -2, 35, black)
  screen.drawText("Game Over", 0, 0, 35, blue)
end



