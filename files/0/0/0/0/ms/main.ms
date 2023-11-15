init = function()
  DEBUGGER = true
  create_popups()
  listen_for_popup_events()
  
  asset_manager.loadFont(font_board)
  settings = read_settings()
  
  // Settings
  cols = 5
  rows = 7
  cell_size = 20
  theme = themes[settings.theme]
  max_player_pieces = 5
  num_player_specials = 1
  num_player_morphemes = 1
  // max_specials = 2
  special_freq_letter = "A"
  special_freq_modifier = 2
  morphemes_modifier = 0.5
  mode = settings.mode
  
  // Set up playing area
  dict = null
  board = null
  tray = null
  curr = null
  letter_bag = null
  daily_words = null
  players = null
  
  // Mobile and mouse controls
  control_move_left = new MoveControl(-screen.width/2+50, -(screen.height/2)+45, true)
  control_move_right = new MoveControl(-screen.width/2+60, -(screen.height/2)+45, false)
  control_rotate = new SelectControl(screen.width/2-75, -(screen.height/2)+30, gray)
  control_select = new SelectControl(screen.width/2-35, -(screen.height/2)+30, red)

  share = new Button("Share", 70, -screen.width/2 + 44, screen.height/2-77)
  play_again = new Button("Play again?", 103, screen.width/2 - 60, screen.height/2-77)
  
  // Set up players
  curr_player = 0

  // Game state
  ready = false
  flash_words = []
  selected_piece = 0 
  specials_used = 0
  game_over = false
  
  reset_game()
  
  if settings.onboarded then
    show_mode()
  else
    settings.onboarded = true
    storage.set('settings', settings)
    show_howto()
  end
end

reset_game = function(selected_mode)
  if selected_mode then mode = selected_mode end
  dict = new Dictionary()
  board = new Board(rows, cols, cell_size) 
  letter_bag = new Letterbag(cols*rows)
  morpheme_bag = new Morphemebag(cols*rows)
  special_bag = new Specialbag(cols*rows)
  tray = new Tray(0, 85)
  curr = new Current(0, 130)
  ready = false
  daily_words = []
  players = []
  game_over = false
  
  if mode == modes.daily then
    loader = asset_manager.loadJSON(daily_path(), function(daily)
      daily_words = daily.words
      dict.add_words(daily.words)
      
      daily.bag = "CAKETAKERAKE LYRERE"
      daily.words = []
      letter_bag = new DailyLetterbag(daily, true)
      morpheme_bag = new DailyMorphemebag(daily, false)
      init_players()
      ready = true
    end)  
  else
    init_players()
    ready = true
  end  
  
  next_round()
end


init_players = function()
  players = [new Player()]
end

update = function()
  if not ready then return end

  if game_over then 
    if share.pressed() then debug("share pressed") end
    if play_again.pressed() then reset_game() end
    return 
  end
  
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
    board.draw(72)
    
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
    
    draw_played_words()

    // Flash words
    flash_words.forEach(function(fw, index) 
      fw.draw(index) 
    end)

    if game_over then
      share.draw()
      play_again.draw()
      draw_game_over()
    end
    
  end
end

read_settings = function()
  prefs = storage.get('settings')
  if not prefs then prefs = object end end
  
  params = read_params()
   
  for p in params
    prefs[p] = params[p]  
  end
  
  for d in defaults
    exist = prefs[d]
    if not exist then prefs[d] = defaults[d] end
  end
  
  prefs
  
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
  local y_offset = 8
  local x_offset = 24
  screen.drawText("WORDS", -screen.width/2+x_offset, screen.height/2-y_offset, font_score_text_size, theme.score_text)
  screen.drawText(current_player().word_count(), -screen.width/2+x_offset, screen.height/2-x_offset, font_score_size, theme.score_text)
  
  screen.drawText("SCORE", screen.width/2-x_offset, screen.height/2-y_offset, font_score_text_size, theme.score_text)
  screen.drawText(current_player().score(), screen.width/2-x_offset, screen.height/2-x_offset, font_score_size, theme.score_text)
end

draw_played_words = function()
  local x = screen.width/2-24
  local i = 1
  for w in current_player().words()
    screen.drawText(w, x, y+95-(i*14), font_score_text_size, black)
    i+=1
  end
end

draw_daily_words = function()
  local results = []
  
  for w in daily_words
    local color = med_gray
    if current_player().results[w] then
      color = red
    end
    results.push(color)
  end
    
  local x = -screen.width/2+24
  local y = 40
  screen.drawText("DAILY", x, y+12, font_score_text_size, theme.score_text)
  screen.drawText("WORDS", x, y, font_score_text_size, theme.score_text)
  
  screen.drawText(daily_words[0], x, y-14, font_score_text_size, results[0])
  screen.drawText(daily_words[1], x, y-28, font_score_text_size, results[1])
  screen.drawText(daily_words[2], x, y-42, font_score_text_size, results[2])  
end

draw_game_over = function()
  local y = screen.height/2-50+font_game_over_offset
  local size = 36
  screen.drawText("GAME OVER", 0, y-2, font_game_over_size, black)
  screen.drawText("GAME OVER", 0, y, font_game_over_size, blue)
end

