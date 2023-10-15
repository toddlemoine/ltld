Letter = class 
  constructor = function(char, size, col)
    this.char = char
    this.col = col
    this.size = size
  end
  
  draw = function(x, y)
    screen.drawRect(x, y, size, size)
    // screen.fillRect(cell_x, cell_y-1, cell_size-1, cell_size-1, yellow)
    screen.drawText(char, x+1, y+1, cell_size, black)  
  end
  
end
