Cell = class
  constructor = function(col, row, size, char=" ")
    this.col = col
    this.row = row
    this.size = size
    this.char = char
    this.x = 0
    this.y = 0
    this.targeted = false
    this.tick = 0
    // 0=normal, 1=selected, 2=exploding, 3=wiggling
    this.state = 0 
    this.selected = false
  end
  
  toJSON = function()
    object
      char = char
      selected = selected
    end
  end
  
  clear = function()
    state = 0
    char = " "
    targeted = false
  end
  
  on = function()
    selected = true
  end
  
  off = function()
    selected = false
  end
  
  calm = function()
    state = 0
  end
  
  explode = function()
    char = " "
    state = 2
  end
  
  wiggle = function()
    state = 3
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

    if selected then
      colors.bg = red
      colors.text = white
    end

    screen.drawRect(x, y, size, size, colors.border)
    screen.fillRect(x, y, size-1, size-1, colors.bg)
    text_x = x
    
    if state == 3 then
      text_x = x + cos(tick)
      tick += .75
    end
    
    screen.drawText(char, text_x, y-font_cell_offset, font_board_size, colors.text)
    
    if state == 2 then
      screen.drawSprite("explosion", x, y, size, size)
    end
    
    
  end

end
