Board = class 
  latest_score = 0
  words_used = []
  
  constructor = function(r, c, cell_size)
    this.c = c
    this.r = r
    this.cell_size = cell_size
    this.grid = []
    
    for i=0 to r-1
      local row = []
      for j=0 to c-1
        row.push(new Cell(j, i, cell_size))
      end
      this.grid.push(row)
    end
  end
  
  filled = function()
    local count = 0
    for row in grid
      for col in row
        if col.char != " " then count += 1 end
      end
    end
    count == c*r
  end
  
  reset_score = function()
    latest_score = 0  
  end
  
  column_is_open = function(col_index)
    grid[0][col_index].char == " "
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
  
  score_cell = function(cell)
    local results = []
    // Score for row
    results = find_words_in_row(grid[cell.row], cell.col)
    
    // col
    results = results.concat(find_words_in_col(column_to_row(cell.col), cell.row))

    // diag left
    results = results.concat(find_words_in_row(diagonal_left(cell.row, cell.col), cell.col))

    // diag right
    results = results.concat(find_words_in_row(diagonal_right(cell.row, cell.col), cell.col))
    
    words = pick(results, "word")
    latest_score += compute_score_for_words(words)
    unique_words = unique(words_used, words)
    words_used = words_used.concat(unique_words)
    
    for w in unique_words
      flash_words.push(new FlashWord(w, 90))
    end
    
    debug(pick(flash_words, "word"))

    // highlight cells
    for r in results
      for rc in r.cells rc.on() end
    end            
  end
    
  
  drop_target_for = function(c, val)
    for i=r-1 to 0
      curr_cell = grid[i][c-1]
      
      if not curr_cell.targeted then 
        debug("setting targeted", i + "," + c-1)
        curr_cell.targeted = true
        return curr_cell
      end
    end
    
    // No available target
    -1
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