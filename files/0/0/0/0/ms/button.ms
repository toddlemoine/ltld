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
    // debug(touch)
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
    screen.drawText(text, attrs.x, attrs.y+1.5, 18, white)    
  end
  
end
