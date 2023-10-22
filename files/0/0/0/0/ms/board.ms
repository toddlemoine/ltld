// Adding a comment to Board
Board = class 
  latest_score = 0
  words_used = []
  
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
  
  reset_score = function()
    latest_score = 0  
  end
  
  column = function(col_index)
    cells = []
    for r in grid
      cells.push(grid[r][col_index])
    end
    cells
  end
  
  drop = function(c, val)
    for i=r to 0
      if grid[i][c-1].char == " " then 
        grid[i][c-1].char = val
        _filled = _filled+1
        // row
        results = find_words_in_row(grid[i], c-1)
        words = pick(results, "word")
        latest_score += compute_score_for_words(words)
        words_used = concat_unique(words_used, words)
        // highlight cells
        for r in results
          for p in r.pos
            grid[i][p].on()
          end
        end
        
        // // col
        // results = find_words_in_row(grid[i], c-1)
        // words = pick(results, "word")
        // latest_score += compute_score_for_words(words)
        // words_used = concat_unique(words_used, words)
        // // highlight cells
        // for r in results
        //   for p in r.pos
        //     grid[i][p].on()
        //   end
        // end
        
        
        // diag left
        // diag right
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