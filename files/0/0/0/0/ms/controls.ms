MoveControl = class 
  constructor = function(x, y, invert)
    this.x = x
    this.y = y
    this.w = 35
    this.invert = invert
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
    
    local color = black
    if hovered() and touch.press then color = gray end
    screen.fillPolygon(c.x1, c.y1, c.x2, c.y2, c.x3, c.y3, color)
  end
  
end

SelectControl = class
  constructor = function(x, y, color)
    this.x = x
    this.y = y
    this.w = 35
    this.color = color
  end
  
  hovered = function()
    touch.y > y-w/2 and touch.y < y+w/2 and touch.x > x-w/2 and touch.x < x+w/2
  end
  
  pressed = function()
    hovered() and touch.release
  end  
  
  draw = function()
    local pressed = hovered() and touch.press
    
    if pressed then
      screen.fillRound(x, y-2, w, w, color)
    else
      screen.fillRound(x, y-2, w, w, black)
      screen.fillRound(x, y, w, w, color)
    end
    
  end
end
