Button = class
  constructor = function(text, x, y, w, h)
    this.text = text
    this.x = x
    this.y = y
    this.w = w
    this.h = h
  end
  
  pressed = function()
    return hovered() and mouse.pressed
  end
  
  hovered = function()
    return mouse.x > x-(w/2) 
      and mouse.x < x+w 
      and mouse.y > y-(h/2) 
      and mouse.y < y+h
  end
  
  draw = function()
    screen.drawRect(x, y, w, h, black)
    
    if hovered() then
      screen.fillRect(x, y, w, h, "rgb(147,49,147)")
    end
    
    screen.drawText(text.toUpperCase(), x, y+1, 12, black)
  end

end