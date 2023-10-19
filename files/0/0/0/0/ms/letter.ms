Letter = class 
  constructor = function(char, size)
    this.char = char
    this.size = size
  end
  
  draw = function(x, y)
    screen.drawRect(x, y, size, size)
    // screen.fillRect(cell_x, cell_y-1, cell_size-1, cell_size-1, yellow)
    screen.drawText(char, x, y, cell_size, black)  
  end
  
end
