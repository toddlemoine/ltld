Cell = class
  constructor = function(col, row, size, char=" ")
    this.col = col
    this.row = row
    this.size = size
    this.char = char
    this.selected = false
    this.x = 0
    this.y = 0
    this.targeted = false
    // 0=normal, 1=selected, 2=exploding
    this.state = 0 
  end
  
  clear = function()
    state = 0
    char = " "
    targeted = false
  end
  
  on = function()
    state = 1
  end
  
  off = function()
    state = 0
  end
  
  explode = function()
    char = " "
    state = 2
  end

  bump = function()
    char = " "
    targeted = null
    state = 0
  end
  
  draw = function()
    local colors = object
      bg = theme.cell_bg
      text = theme.cell_text
      border = theme.cell_border
    end

    if state == 1 then
      colors.bg = red
      colors.text = white
    end

    screen.drawRect(x, y, size, size, colors.border)
    screen.fillRect(x, y, size-1, size-1, colors.bg)
    screen.drawText(char, x, y, cell_size-2, colors.text)
    
    if state == 2 then
      screen.drawSprite("explosion", x, y, size, size)
    end
  end

end
