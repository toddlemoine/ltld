MoveControl = class 
  constructor = function(x, y, invert)
    this.x = x
    this.y = y
    this.w = 35
    this.invert = invert
  end
  
  hovered = function()
    local in_y = mouse.y > y-w and mouse.y < y+w
    
    if invert then 
      return in_y and mouse.x > x-w and mouse.x < x 
    else
      return in_y and mouse.x > x and mouse.x < x+w 
    end
  end
  
  pressed = function()
    hovered() and mouse.release
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
    if hovered() and mouse.pressed then color = gray end
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
    mouse.y > y-w/2 and mouse.y < y+w/2 and mouse.x > x-w/2 and mouse.x < x+w/2
  end
  
  pressed = function()
    hovered() and mouse.release
  end  
  
  draw = function()
    local pressed = hovered() and mouse.pressed
    
    if pressed then
      screen.fillRound(x, y-2, w, w, color)
    else
      screen.fillRound(x, y-2, w, w, black)
      screen.fillRound(x, y, w, w, color)
    end
    
  end
end
