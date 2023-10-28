Cell = class
  constructor = function(col, row, size, char=" ")
    this.col = col
    this.row = row
    this.size = size
    this.char = char
    this.selected = false
  end
  
  on = function()
    selected = true  
  end
  
  draw = function(x, y)
    local colors = object
      bg = white
      text = black
      border = black
    end

    if selected then
      colors.bg = green
      colors.text = white
    end
    
    screen.drawRect(x, y, size, size, colors.border)
    screen.fillRect(x, y, size-1, size-1, colors.bg)
    screen.drawText(char, x, y, cell_size-2, colors.text)
  end

end
