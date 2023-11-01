BombSpecial = class
  constructor = function(x, y)  
    this.w = cell_size
    this.h = cell_size
    this.x = x
    this.y = y
    this.length = 1
  end
  
  draw = function()
    screen.drawSprite("special_bomb", x, y, w, h)
  end
    
end
