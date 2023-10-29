Letter = class 
  constructor = function(char, size, x, y)
    this.char = char
    this.size = size
    this.selected = false
    this.target = null
    this.x = x
    this.y = y
  end
  
  on = function()
    selected = true  
  end
  
  at_target = function()
    if target != null then
      return y == target.y and x == target.x
    end
    false
  end
  
  update = function()
    if target != null then
      y = max(target.y, y-5)
      if at_target() then
        target.char = char
        board.score_cell(target)
      end
    end
  end
  
  draw = function()
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
