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
        row.push(new Cell(j, i, cell_size))
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
  
  column_to_row = function(col_index)
    cells = []
    for r in grid
      cells.push(r[col_index])
    end
    cells
  end
  
  diagonal_left = function(row_index, col_index)
    cells = []
    
    // find the start
    pos = object
      r = row_index
      c = col_index
    end
  
    done = false
    
    while not done
      next = grid[pos.r][pos.c]
      if not next then
        done = true
      else
        cells.push(next)
        pos.r = pos.r+1
        pos.c = pos.c-1
      end
    end
    
    cells = reverse(cells)

    // find the end
    done = false
    
    pos.r = row_index-1
    pos.c = col_index+1
    
    while not done
      next = grid[pos.r][pos.c]
      if not next then
        done = true
      else
        cells.push(next)
        pos.r = pos.r-1
        pos.c = pos.c+1
      end
    end
    
    cells
  end
  
  diagonal_right = function(row_index, col_index)
    cells = []
    
    // find the start
    pos = object
      r = row_index
      c = col_index
    end
  
    done = false
    
    while not done
      next = grid[pos.r][pos.c]
      if not next then
        done = true
      else
        cells.push(next)
        pos.r = pos.r-1
        pos.c = pos.c-1
      end
    end
    
    cells = reverse(cells)

    // find the end
    done = false
    
    pos.r = row_index+1
    pos.c = col_index+1
    
    while not done
      next = grid[pos.r][pos.c]
      if not next then
        done = true
      else
        cells.push(next)
        pos.r = pos.r+1
        pos.c = pos.c+1
      end
    end
    
    cells
  end
    
  
  drop_target_for = function(c, val)
    
    for i=r-1 to 0
      curr_cell = grid[i][c-1]
      
      if not curr_cell.targeted then 
        curr_cell.targeted = true
        return curr_cell
        
        // pos.r = i        
        // pos.x = grid[i][c-1].x
        // pos.y = grid[i][c-1].y
        // grid[i][c-1].char = val
        // _filled = _filled+1
        
        // // Score for row
        // results = find_words_in_row(grid[i], c-1)
        
        // // col
        // results = results.concat(find_words_in_col(column_to_row(c-1), i))

        // // diag left
        // results = results.concat(find_words_in_row(diagonal_left(i, c-1), c-1))

        // // diag right
        // results = results.concat(find_words_in_row(diagonal_right(i, c-1), c-1))
        
        // words = pick(results, "word")
        // latest_score += compute_score_for_words(words)
        // unique_words = unique(words_used, words)
        // words_used = words_used.concat(unique_words)
        
        // for w in unique_words
        //   flash_words.push(new FlashWord(w, 90))
        // end
        
        // debug(pick(flash_words, "word"))

        // // highlight cells
        // for r in results
        //   for cell in r.cells cell.on() end
        // end        
        break
      end
    end
  end
  
  draw = function(y)
    local x_offset = cell_size*c/2-cell_size/2

    for i=0 to grid.length-1
      for j=0 to grid[i].length-1
        grid[i][j].x = -(x_offset-cell_size*j)
        grid[i][j].y = y-cell_size*i
        grid[i][j].draw()
      end
    end
  end

end