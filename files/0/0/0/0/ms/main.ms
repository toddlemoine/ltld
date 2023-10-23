init = function()
  DEBUGGER = true
  
  cols = 5
  rows = 7
  cell_size = 20
  
  dict = new Dictionary()
  board = new Board(rows, cols, cell_size) 
  letter_bag = new Letterbag(cols*rows)
  reset = new Button("Reset", -140, 90, 35, 15)

  curr = ""
  curr_y = 150 // y offset for current letter in play
  curr_col = round(cols/2)
  curr_pos = 1
  piece_y = -90 // y offset for piece tray
  selected_piece = 0 // selected piece  
  
  game_over = false
  
  max_player_pieces = 3
  curr_player = 0
  players = [new Player()]
  
end

update = function()
  if game_over then 
    return 
  end

  if curr == "" then
    if keyboard.press.LEFT then
      piece_move_left()
      
    elsif keyboard.press.RIGHT then
      piece_move_right()
  
    elsif keyboard.press.ENTER then
      curr = next_current(players[curr_player].select(selected_piece))
    end
    
  else
    if keyboard.press.LEFT then
      move_left()
      
    elsif keyboard.press.RIGHT then
      move_right()
  
    elsif keyboard.press.UP then
      if can_rotate() then rotate() end
  
    elsif keyboard.press.ENTER then
      drop_curr()
      current_player().add_points(board.latest_score)
      debug("TOTAL WORDS: " + board.words_used)
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
  
  board.draw(80)
  
  // Letter drawing
  draw_curr()
  
  // Player
  current_player().draw_pieces()
  
  // Score
  draw_score()

  // Reset
  reset.draw()
  
  if game_over then
    draw_game_over()
  end
end

current_player = function()
  players[curr_player]  
end

next_round = function()
  board.reset_score()
  curr_pos = 1
  curr_col = round(cols/2)
  curr = ""
end

reset_game = function()
  board = new Board(rows, cols, cell_size) 
  letter_bag = new Letterbag()
  game_over = false
  next_round()
end

draw_score = function()
  text = "SCORE: " + current_player().score
  screen.drawText(text, 0, -screen.height/2+12, 20, black)
end

draw_game_over = function()
  screen.drawText("Game Over", 2, -2, 35, black)
  screen.drawText("Game Over", 0, 0, 35, blue)
end

