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
  max_specials = 2
  max_player_pieces = 3
  
  // Set up playing area
  dict = new Dictionary()
  board = new Board(rows, cols, cell_size) 
  letter_bag = new Letterbag(cols*rows)
  special_chooser = new SpecialChooser(0, -(screen.height/2)+45)
  curr = new Current(0, 150)
  
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
    
  // elsif curr.dropping then
  //   curr.update()
    
  else

    // Something is selected. Move and drop.

    if keyboard.press.LEFT then
      curr.move_left()
      
    elsif keyboard.press.RIGHT then
      curr.move_right()
  
    elsif keyboard.press.UP then
      curr.rotate()
      
    elsif keyboard.press.ENTER then
      curr.drop()

      // current_player().add_points(board.latest_score)
      // debug("TOTAL WORDS: " + board.words_used)
    end
    
    curr.update()
    
    // if board.filled() then
    //   game_over = true
    // else
    //   next_round()
    // end
    
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
    
    // Player
    current_player().draw_pieces()
    
    // Score
    draw_score()
    
    // Flash words
    map(flash_words, function(fw, index) 
      fw.draw(index) 
    end)
    
    special_chooser.draw()
  
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
  curr = new Current(0, 150)
end

reset_game = function()
  board = new Board(rows, cols, cell_size) 
  special_chooser.reset()
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
  text = "WORDS: " + board.words_used.length + " / SCORE: " + current_player().score
  screen.drawText(text, 0, -screen.height/2+12, 17, black)
end

draw_game_over = function()
  screen.drawText("Game Over", 2, -2, 35, black)
  screen.drawText("Game Over", 0, 0, 35, blue)
end



