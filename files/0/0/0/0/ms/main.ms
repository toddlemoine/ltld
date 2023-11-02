init = function()
  DEBUGGER = true
  
  cols = 5
  rows = 7
  cell_size = 20
  game_over = false
  
  flash_words = []
  piece_y = -90 // y offset for piece tray
  selected_piece = 0 // selected piece  
  specials_used = 0
  max_player_pieces = 4
  
  // Set up playing area
  dict = new Dictionary()
  board = new Board(rows, cols, cell_size) 
  letter_bag = new Letterbag(cols*rows)
  tray = new Tray(0, -(screen.height/2)+45)
  curr = new Current(0, 140)
  
  // Set up players
  curr_player = 0
  players = [new Player()]

  reset = new Button("Reset", -80, -167, 35, 15)
  
end

update = function()
  if game_over then return end
  
  update_flash_words()

  if curr.is_pending() then
    if keyboard.press.LEFT then
      piece_move_left()
      
    elsif keyboard.press.RIGHT then
      piece_move_right()

    elsif keyboard.press.DOWN then
      piece_move_down()

    elsif keyboard.press.UP then
      piece_move_up()
  
    elsif keyboard.press.ENTER then
      curr.set_pieces(current_player().select(selected_piece))
    end
    
  else
    
    if not curr.dropping then

      // Something is selected. Move and drop.
      if keyboard.press.LEFT then
        curr.move_left()
        
      elsif keyboard.press.RIGHT then
        curr.move_right()
    
      elsif keyboard.press.UP then
        curr.rotate()

      elsif keyboard.press.DOWN then
        curr.rotate(true)
        
      elsif keyboard.press.ENTER then
        curr.drop()
      end

    end
    
    curr.update()

    if curr.done then
      current_player().add_results(board.latest_results)
      debug("TOTAL WORDS: " + board.words_used())
      
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
  text = "WORDS: " + current_player().word_count() + " / SCORE: " + current_player().score()
  screen.drawText(text, 0, -screen.height/2+12, 17, black)
end

draw_game_over = function()
  screen.drawText("Game Over", 2, -2, 35, black)
  screen.drawText("Game Over", 0, 0, 35, blue)
end



