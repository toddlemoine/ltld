MoveControl = class 
  constructor = function(x, y, invert)
    this.x = x
    this.y = y
    this.w = 35
    this.invert = invert
  end
  
  clone = function()
    new MoveControl(x, y, invert)
  end
  
  hovered = function()
    local in_y = touch.y > y-w and touch.y < y+w
    
    if invert then 
      return in_y and touch.x > x-w and touch.x < x 
    else
      return in_y and touch.x > x and touch.x < x+w 
    end
  end
  
  pressed = function()
    hovered() and touch.release
  end
  
  draw = function()
    local c = object
      x1 = x
      y1 = y
    end
    
    if not invert then
      c.x2 = c.x1 + w
    else
      c.x2 = c.x1 - w
    end
    
    c.y2 = c.y1 - w/2
    c.x3 = c.x1 
    c.y3 = c.y1 - w
    
    local color = theme.move_control
    local pressed = hovered() and touch.touching
    if pressed then color = gray end
    if pressed then
      screen.fillPolygon(c.x1, c.y1-2, c.x2, c.y2-2, c.x3, c.y3-2, gray)
    else
      screen.fillPolygon(c.x1, c.y1-2, c.x2, c.y2-2, c.x3, c.y3-2, black)
      screen.fillPolygon(c.x1, c.y1, c.x2, c.y2, c.x3, c.y3, gray)      
    end
  end
  
end

SelectControl = class
  constructor = function(x, y, color)
    this.x = x
    this.y = y
    this.w = 35
    this.color = color
  end
  
  clone = function()
    new SelectControl(x, y, color)
  end
  
  hovered = function()
    touch.y > y-w/2 and touch.y < y+w/2 and touch.x > x-w/2 and touch.x < x+w/2
  end
  
  pressed = function()
    hovered() and touch.release
  end  
  
  draw = function()
    local pressed = hovered() and touch.touching
    
    if pressed then
      screen.fillRound(x, y-2, w, w, color)
    else
      screen.fillRound(x, y-2, w, w, black)
      screen.fillRound(x, y, w, w, color)
    end
    
  end
end

RotateControl = class extends SelectControl
  constructor = function(x, y, color)
    super(x, y, color)
  end
  draw = function()
    super()
    screen.drawArc(0, 0, 10, 100, 10, false, black)
    // x, y, radius, angle1, angle2, ccw, color
  end
end


PauseControl = class
  constructor = function(x, y, color = gray)
    this.x = x
    this.y = y
    this.w = 15
    this.h = 8
    this.r = 25
    this.color = color
  end
  
  hovered = function()
    touch.y > y-w/2 and touch.y < y+w/2 and touch.x > x-w/2 and touch.x < x+w/2
  end
  
  pressed = function()
    hovered() and touch.release
  end  
  
  draw = function()
    local pressed = hovered() and touch.touching
    
    if pressed then
      screen.fillRoundRect(x, y-2, w, h, r, color)
    else
      screen.fillRoundRect(x, y-2, w, h, r, black)
      screen.fillRoundRect(x, y, w, h, r, color)
    end
    
    screen.drawText(messages.controls_help, x, y+h+2, 6)
    
  end
end

