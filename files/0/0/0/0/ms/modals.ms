
SelectModal = class
  constructor = function()
    this.x = 0
    this.y = 0
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
  
  draw = function()
    local height = screen.height*.85
    screen.fillRect(x, y, screen.width, screen.height, "rgba(0,0,0,.6)")
    screen.fillRoundRect(x, y-2, screen.width*.8, height, 8, black)
    screen.fillRoundRect(x, y, screen.width*.8, height, 8, white)

    screen.drawText("Help", 0, (height/2)-24, 24, blue)
    local lines = [
      "Drop letters to make words",
      "in any direction. Score points "
      "for 4 & 5 letter words.",
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
