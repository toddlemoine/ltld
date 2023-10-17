// Adding a comment to Board
Board = class 
  constructor = function(r, c, cell_size)
    this.c = c
    this.r = r
    this.cell_size = cell_size
    this.grid = []
    this._filled = 0
    
    for i=0 to r-1
      local row = []
      for j=0 to c-1
        row.push(new Letter(" ", cell_size))
      end
      this.grid.push(row)
    end
  end
  
  filled = function() 
    _filled == c*r
  end
  
  
  drop = function(c, val)
    for i=r to 0
      if grid[i][c-1].char == " " then 
        grid[i][c-1].char = val
        _filled = _filled+1
        break
      end
    end
  end
  
  draw = function(y)
    local x_offset = cell_size*c/2-cell_size/2

    for i=0 to grid.length-1
      for j=0 to grid[i].length-1
        local cell_x = x_offset-cell_size*j
        local cell_y = y-cell_size*i
        grid[i][j].draw(-cell_x, cell_y)
      end
    end
  end

end