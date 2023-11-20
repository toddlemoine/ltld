Toggle = class
  constructor = function(x, y, labels)
    this.x = x
    this.y = y
    this.h = 25
    this.w = 40
    this.r = 25
    this.labels = labels
    this.value = 0
  end
  hovered = function()
    local half_h = h/2
    local half_w = w/2
    local in_y = touch.y < y+half_h and touch.y > y-half_h
    return in_y and touch.x > x-half_w and touch.x < x+half_w
  end
  
  pressed = function()
    hovered() and touch.release
  end
  
  update = function()
  end
  
  draw = function(y)
    screen.drawRoundRect(x, y, w, h, r, blue)
    
    // Toggle
    local t_h = h-4
    local t_pad = 2
    local t_x = x-w/2+t_h/2+t_pad
    if value == "1" then
      t_x = x+(w/2)-t_h/2-t_pad
    end
    screen.fillRound(t_x,y,t_h, t_h, blue)
    
    // Labels
    local text_w = screen.textWidth(labels[0], 8)
    screen.drawText(labels[0], x-w/2-text_w/2-5, y, 8, theme.modal_text)
    
    local text_w = screen.textWidth(labels[1], 8)
    screen.drawText(labels[1], x+w/2+text_w/2+5, y, 8, theme.modal_text)
  end
end



Button = class
  constructor = function(text, width, x, y)
    this.text = text
    this.radius = radius
    this.width = width
    this.color = blue
    this.x = x
    this.y = y
  end
  
  hovered = function()
    local in_y = touch.y < y+6 and touch.y > y-6
    return in_y and touch.x > x-width/2 and touch.x < x+width/2
  end
  
  pressed = function()
    hovered() and touch.release
  end
  
  draw = function()
    local pressing = hovered() and touch.touching
    local attrs = object
      color = color
      x = x
      y = y
    end
    if pressing then 
      attrs.color = gray 
      attrs.y = y-2
    end
    if not pressing then
      screen.fillRoundRect(attrs.x, attrs.y-2, width, 20, 25, black)      
    end
    screen.fillRoundRect(attrs.x, attrs.y, width, 20, 25, color)
    screen.drawText(text, attrs.x, attrs.y+font_game_over_button_text_offset, font_game_over_button_size, white)    
  end
  
end
