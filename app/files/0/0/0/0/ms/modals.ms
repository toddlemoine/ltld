Modal = class
  constructor = function()
    this.x = 0
    this.y = 0
  end
  draw = function()
    local height = screen.height*.85
    screen.fillRect(x, y, screen.width, screen.height, "rgba(0,0,0,.7)")
    screen.fillRoundRect(x, y-2, screen.width*.8, height, 8, black)
    screen.fillRoundRect(x, y, screen.width*.8, height, 8, theme.modal_bg)
  end
  
end


MiniControls = class
  constructor = function(y)
    this.y = y
    local controls = object
      move_left = control_move_left.clone()
      move_right = control_move_right.clone()
      rotate = control_rotate.clone()
      select = control_select.clone()
    end
    
     for c in controls 
        controls[c].y = controls[c].y+y
     end
    
    this.controls = controls
  end

  draw_callout = function(text, x, y)
    screen.drawLine(x, y, x, y-10, theme.modal_text)
    screen.drawText(text, x, y-20, 7, theme.modal_text)
  end
  
  draw = function()   
    screen.setScale(.65, .65)
    for c in controls controls[c].draw() end
    screen.setScale(1, 1)
    
    draw_callout("Move", -29, controls.move_left.y-16)
    draw_callout("Rotate", 19, controls.rotate.y)
    draw_callout("Use/Drop", 43, controls.select.y-7)
  end
  
end

    

OnboardingModal = class extends Modal
 constructor = function()
    super()
    this.mini_controls = new MiniControls(100)

    this.buttons = object
      ok = new Button("Ok", 100, 0, 0)
    end
  end

  update = function()
    if buttons.ok.pressed() then 
      clear_modal()
    end
  end
  
  draw = function()
    super()
    local height = screen.height*0.85

    screen.drawText("How to Play", 0, (height/2)-24, 18, blue)
    local lines = [
      "Select letters from your tray"
      "to drop on the board. Make words",
      "in any direction. Score points",
      " for 4, 5, & 6-letter words."
    ].forEach(function(line, index)
      screen.drawText(line, 0, (height/2)-48-(index*12), 7.5, theme.modal_text)
    end)
    
    lines = ["Every day, everyone gets 3 words "
    "for the day and the same letters",
    "to use. Try to make all three!"].forEach(function(line, index)
      screen.drawText(line, 0, 46-(index*12), 7.5, red)
    end)

    // Controls
    screen.drawText("Controls", 0, 0, 10, blue)
    mini_controls.draw()
    
    local lines = [
      "Desktop folks: Use arrow keys",
      "to move and rotate, Enter"
      "or Space to select & drop.",
    ].forEach(function(line, index)
      screen.drawText(line, 0, -85-(index*12), 7.5, theme.modal_text)
    end)
    
    
    local count = 0
    for b in buttons
      btn = buttons[b]
      btn.y = -height/2+20+count*10
      btn.draw()
      count+=1
    end

  end
end  



SelectModal = class extends Modal
  constructor = function()
    super()
    this.controls = new MiniControls()
    this.controls = object
      move_left = control_move_left.clone()
      move_right = control_move_right.clone()
      rotate = control_rotate.clone()
      select = control_select.clone()
    end
    
    local buttons = object
      restart = new Button("Restart", 100, 0, 0)
      mode = new Button("Daily Mode", 100, 0, 0)
      back = new Button("Back to Game", 100, 0, 0)
    end

    if mode == modes.daily then
      buttons.mode.text = "Freeplay Mode"
    end
    
    this.buttons = buttons
    this.position_controls()
  end
  
  position_controls = function()
    for c in controls 
      controls[c].y = controls[c].y+215
    end
  end
  
  draw_callout = function(text, x, y)
    screen.drawLine(x, y, x, y-10, black)
    screen.drawText(text, x, y-20, 7, black)
  end
  
  update = function() 
    if buttons.back.pressed() then 
      clear_modal()
    end
    
    if buttons.restart.pressed() then 
      track_event(events.restart, object mode = mode end)
      reset_game()
    end
    
    if buttons.mode.pressed() then 
      if mode == modes.daily then
        track_event(events.switch_mode, object to = modes.free end)
        reset_game(modes.free)
      else
        track_event(events.switch_mode, object to = modes.daily end)
        reset_game(modes.daily)
      end
    end
  end  
  
  draw = function()
    super()
    local height = screen.height*0.85
    screen.drawText("Help", 0, (height/2)-24, 18, blue)
    local lines = [
      "Drop letters to make words",
      "in any direction. Score points "
      "for 4, 5, & 6-letter words.",
    ].forEach(function(line, index)
      screen.drawText(line, 0, (height/2)-48-(index*12), 7.5, black)
    end)

    // Controls
    screen.setScale(.65, .65)
    for c in controls 
      controls[c].draw() 
    end
    screen.setScale(1, 1)
    
    local callout_y = 28
    draw_callout("Move", -29, callout_y)
    draw_callout("Rotate", 19, callout_y)
    draw_callout("Use/Drop", 43, callout_y+13)
    
    local lines = [
      "Desktop: Use arrow keys",
      "to move and rotate, Enter"
      "or Space to select & drop.",
    ].forEach(function(line, index)
      screen.drawText(line, 0, -15-(index*12), 7.5, black)
    end)
    
    
    local count = 0
    for b in buttons
      btn = buttons[b]
      btn.y = -65-(count*30)
      btn.draw()
      count+=1
    end
  end
end

SettingsModal = class extends Modal
  constructor = function()
    super()
    this.buttons = object
      theme = new Toggle(0,80, ["Light", "Dark"])
      mode = new Toggle(0,20, ["Daily", "Freeplay"])
      feedback = new Button("Give Feedback", 100, 0, -64)
      back = new Button("Back to Game", 100, 0, -130)
    end
  end
  
  update = function()
    if settings.theme == "light" then
      buttons.theme.value = "0"
    else
      buttons.theme.value = "1"
    end
    
    buttons.mode.value = settings.mode
    
    if buttons.theme.pressed() then
      toggle_settings_theme()
      track_event(events.toggle_theme, object to = settings.theme end)      
    end

    if buttons.mode.pressed() then
      toggle_settings_mode()
      track_event(events.toggle_default, object to = settings.mode end)
    end
    
    if buttons.feedback.pressed() then
      go_to_url(urls.feedback)
    end
    
    if buttons.back.pressed() then
      clear_modal()
    end    
  end
  
  draw = function()
    super()
    local height = screen.height*0.85
    local half_h = height/2
    screen.drawText("Settings", 0, half_h-24, 18, blue)
    screen.drawText("Theme", 0, half_h-48, 7.5, theme.modal_text)    
    buttons.theme.draw(half_h-70)

    screen.drawText("Default Mode", 0, half_h-108, 7.5, theme.modal_text)    
    buttons.mode.draw(half_h-130)
    
    screen.drawText("Feedback", 0, half_h-168, 7.5, theme.modal_text)    
    local lines = [
      "Suggest a word, report a ",
      "bug, or contact us."
    ].forEach(function(line, index)
      screen.drawText(line, 0, half_h-182-(index*12), 7.5, theme.modal_text)
    end)
    
    buttons.feedback.draw()
    buttons.back.draw()
  end
end

  
