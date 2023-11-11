Button = class
  constructor = function(text, radius, width, color)
    this.text = text
    this.radius = radius
    this.width = width
    this.color = color
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

    local color = this.color
    if hovered() and touch.press then color = gray end
    // screen.fillPolygon(c.x1, c.y1, c.x2, c.y2, c.x3, c.y3, color)
    screen.fillRoundRect(x, y-2, 103, 20, 25, black)
    screen.fillRoundRect(x, y, 103, 20, 25, blue)
    screen.drawText("Play again?", x, y+2, 18, white)    
  end
  
end
