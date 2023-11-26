init = function()
  DEBUGGER = true
  create_page_elements(urls)

  loader = asset_manager.loadFont(font_board)
  settings = read_settings()
  
  // Settings
  cols = 5
  rows = 7
  cell_size = 20
  max_player_pieces = 5
  num_player_specials = 1
  num_player_morphemes = 1
  // max_specials = 2
  special_freq_letter = "A"
  special_freq_modifier = 2
  morphemes_modifier = 0.5
  mode = settings.mode
  
  // Set up playing area
  board_y = 78
  dict = null
  board = null
  tray = null
  curr = null
  letter_bag = null
  daily_words = null
  players = null
  
  // Mobile and mouse controls
  control_pause = new PauseControl(-11, -(screen.height/2)+60, messages.controls_help)
  control_settings = new PauseControl(11, -(screen.height/2)+60, "Set")
  control_move_left = new MoveControl(-screen.width/2+50, -(screen.height/2)+45, true)
  control_move_right = new MoveControl(-screen.width/2+60, -(screen.height/2)+45, false)
  control_rotate = new RotateControl(screen.width/2-70, -(screen.height/2)+30, gray)
  control_select = new SelectControl(screen.width/2-35, -(screen.height/2)+50, red)
  about_link = new AboutLink("About", screen.width/2-18, screen.height/2-8, 6, white)

  // Modals
  modal = null
  
  // Set up players
  curr_player = 0

  // Game state
  ready = false
  flash_words = []
  selected_piece = 0 
  // specials_used = 0
  game_over = false

  reset_game()
  
  if not settings.onboarded then
    settings.onboarded = true
    save_settings()
    modal = new OnboardingModal()
  end
end

reset_game = function(selected_mode)
  if selected_mode then mode = selected_mode end
  dict = new Dictionary()
  board = new Board(rows, cols, cell_size) 
  letter_bag = new Letterbag(cols*rows)
  morpheme_bag = new Morphemebag(cols*rows)
  special_bag = new Specialbag(cols*rows)
  select_modal = new SelectModal()
  tray = new Tray(0, -80, cell_size)
  curr = new Current(0, 125)
  ready = false
  daily_words = []
  flash_words = []
  players = []
  game_over = false
  
  modal = null
  
  if mode == modes.daily then
    loader = asset_manager.loadJSON(daily_path(), function(daily)
      daily_words = daily.words
      dict.add_words(daily.words)
      
      // daily.bag = "PADEPPAAPQ RYLYRERE"
      // daily.words = []
      letter_bag = new DailyLetterbag(daily, false)
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
  theme = themes[settings.theme]
  
  if not ready then return end
  
  if loader.ready then
    set_font_offsets()
  end
  
  if game_over then 
    if not modal then 
      modal = new SummaryScreen()
      track_event(events.finished)
    end
  end
  
  if modal then
    modal.update()
    return
  else 
    if control_pause.pressed() then
      modal = new SelectModal()
      track_event(events.help_pushed)
    end
    if control_settings.pressed() then
      modal = new SettingsModal()
      track_event(events.settings_pushed)
    end    
  end
  
  about_link.update()
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
        curr.rotate_ccw()

      elsif controls.down() then
        curr.rotate()
        
      elsif controls.select() then
        curr.drop()
      end

    end
    
    curr.update()

    if curr.done then
      board.update()
      
      debug("TOTAL WORDS: " + board.words_used())
      debug("PLAYER WORDS: " + current_player().words())
      
      if board.filled() or current_player().cant_play() then
        game_over = true
      else
        next_round()  
      end
    end
    
  end
  
end

clear_modal = function()
  modal = null
end

draw = function()
  screen.clear(theme.game_bg)
  screen.setFont(font_board)

  if ready and screen.isFontReady(font_board) then  
    draw_copyright()
    
    board.draw(board_y)
    
    control_pause.draw()
    control_settings.draw()
    control_move_right.draw()
    control_rotate.draw()
    control_select.draw()
    control_move_left.draw()
    
    // Letter drawing
    curr.draw()
    
    // Tray with pieces
    tray.draw(current_player().pieces)
    
    if_daily(draw_daily_words)
    
    draw_played_words()

    // Flash words
    flash_words.forEach(function(fw, index) 
      fw.draw(index) 
    end)

    // Score
    draw_score()

    if modal then
      modal.draw()
    end
    
    draw_header()

  end
end

set_font_offsets = function()
  if is_safari() then
    font_cell_offset = 0
    font_game_over_offset = 3
    font_game_over_button_text_offset = 0
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
  up = function() keyboard.press.W or keyboard.press.UP end
  down = function() keyboard.press.S or keyboard.press.DOWN or control_rotate.pressed() end
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
  local y_offset = 24
  local x_offset = 18
  screen.drawText(messages.score_words, -screen.width/2+x_offset, screen.height/2-y_offset, font_score_text_size, theme.score_text)
  screen.drawText(current_player().word_count(), -screen.width/2+x_offset, screen.height/2-y_offset-14, font_score_size, theme.score_text)
  
  screen.drawText(messages.score_score, screen.width/2-x_offset, screen.height/2-y_offset, font_score_text_size, theme.score_text, white)
  screen.drawText(current_player().score(), screen.width/2-x_offset, screen.height/2-y_offset-14, font_score_size, theme.score_text)
end

draw_played_words = function(color = theme.score_text)
  local x = screen.width/2-24
  local i = 1
  local words = current_player().words()
  local sp = 14
  if words.length > 10 then sp = 11 end
  local y_offset = 8*(words.length+sp)/2
  for w in words
    screen.drawText(w, x, y+y_offset-(i*sp), font_score_text_size, color)
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
  screen.drawText(messages.todays, x, y+12, font_score_text_size, theme.score_text)
  screen.drawText(messages.words, x, y, font_score_text_size, theme.score_text)
  
  screen.drawText(daily_words[0], x, y-14, font_score_text_size, results[0])
  screen.drawText(daily_words[1], x, y-28, font_score_text_size, results[1])
  screen.drawText(daily_words[2], x, y-42, font_score_text_size, results[2])  
end

draw_mode = function()
  local text = if mode == modes.daily then messages.daily else messages.freeplay end
  screen.drawText(text, 0, screen.height/2-26, 7, white)
end

draw_header = function()
  screen.fillRect(0, screen.height/2-2, screen.width, 29, "rgba(0,0,0,.5)")  
  screen.fillRect(0, screen.height/2, screen.width, 29, red)
  screen.drawText("Let The Letter Drop", 0, screen.height/2-8, 9, white)
  about_link.draw()
end

draw_copyright = function()
  local w = screen.textWidth(messages.copyright, 5)
  screen.drawText(messages.copyright, screen.width/2-w/2-2, -screen.height/2+4, 5, theme.copyright)  
end





