init = function()
  DEBUGGER = true
  
  // Settings
  cols = 5
  rows = 7
  cell_size = 20
  theme = themes.light
  max_player_pieces = 4
  max_specials = 2
  special_freq_letter = "A"
  special_freq_modifier =  2
  morphemes_modifier = 0.5
  mode = modes.daily
  
  // Set up playing area
  dict = new Dictionary()
  board = new Board(rows, cols, cell_size) 
  tray = new Tray(0, 90)
  curr = new Current(0, 140)
  letter_bag = new Letterbag(cols*rows)
  daily_words = []
  
  // Mobile and mouse controls
  control_move_left = new MoveControl(-screen.width/2+50, -(screen.height/2)+45, true)
  control_move_right = new MoveControl(-screen.width/2+60, -(screen.height/2)+45, false)
  control_rotate = new SelectControl(screen.width/2-75, -(screen.height/2)+30, gray)
  control_select = new SelectControl(screen.width/2-35, -(screen.height/2)+30, red)
  
  // Set up players
  curr_player = 0
  players = []

  // Game state
  ready = false
  flash_words = []
  selected_piece = 0 // selected piece  
  specials_used = 0
  game_over = false
  assets_loaded = false
  
  // For daily mode, we need to load the daily data
  // and use it to generate the letterbag.
  if mode == modes.daily then
    loader = asset_manager.loadJSON(daily_path(), function(daily)
      daily_words = daily.words
      dict.add_words(daily.words)
      
      // daily.bag = "DELFSTINT"
      // daily.words = []
      
      letter_bag = new DailyLetterbag(daily, false)
      init_players()
      ready = true
    end)  
  else
    init_players()
    ready = true
  end

end

init_players = function()
  players.push(new Player())
end

update = function()
  if not ready then return end
  if game_over then return end
  
  update_flash_words()

  // Selecting a piece to drop
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
      
      // Moving into position to drop
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
  
end

draw = function()
  screen.clear(theme.game_bg)
  screen.setFont(font_board)
  
  if ready and screen.isFontReady(font_board) then  
    board.draw(80)
    
    control_move_right.draw()
    control_rotate.draw()
    control_select.draw()
    control_move_left.draw()
    
    // Letter drawing
    curr.draw()
    
    // Tray with pieces
    tray.draw(current_player().pieces)
    
    // Score
    draw_score()
    
    if_daily(draw_daily_words)

    // Flash words
    flash_words.forEach(function(fw, index) 
      fw.draw(index) 
    end)

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

if_daily = function(fn)
  if mode == modes.daily then fn() end
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
  screen.drawText("WORDS", -screen.width/2+20, screen.height/2-6, 12, theme.score_text)
  screen.drawText(current_player().word_count(), -screen.width/2+20, screen.height/2-20, 20, theme.score_text)
  
  screen.drawText("SCORE", screen.width/2-20, screen.height/2-6, 12, theme.score_text)
  screen.drawText(current_player().score(), screen.width/2-20, screen.height/2-20, 20, theme.score_text)

end

draw_daily_words = function()
  local widths = object
    w1 = screen.textWidth(daily_words[0], 12)
    w2 = screen.textWidth(daily_words[1], 12)
    w3 = screen.textWidth(daily_words[2], 12)
    sp = 6
  end
  
  local total = widths.w1 + sp + widths.w2 + sp + widths.w3
  
  local results = []
  
  for w in daily_words
    local color = med_gray
    if current_player().results[w] then
      color = red
    end
    results.push(color)
  end
    
  // screen.drawText(daily_words[0], -(widths.w1+widths.w2+widths.sp+widths.sp)/2, screen.height/2-6, 12, results[0])
  // screen.drawText(daily_words[1], 0, screen.height/2-6, 12, results[1])
  // screen.drawText(daily_words[2], (total+widths.sp-widths.w3)/2, screen.height/2-6, 12, results[2])  

  local x = -screen.width/2+20
  screen.drawText("BONUS", x, screen.height/2-40, 12, theme.score_text)
  
  screen.drawText(daily_words[0], x, screen.height/2-54, 12, results[0])
  screen.drawText(daily_words[1], x, screen.height/2-68, 12, results[1])
  screen.drawText(daily_words[2], x, screen.height/2-82, 12, results[2])  



end


draw_game_over = function()
  screen.drawText("Game Over", 2, -2, 35, black)
  screen.drawText("Game Over", 0, 0, 35, blue)
end



