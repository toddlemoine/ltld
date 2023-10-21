// Adding a comment to Board
Board = class 
  latest_score = 0
  
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
  
  compute_score = function(r, c)
    // Compute 5-letter words first
    // If none, then look for 4-letter words
    // If none, then 3-letter words
    
    words_found = []
    row = grid[r]
    
    // word = word_at(row, 0, 5)
    // if word then words_found.push(word) end
    // word = rev_word_at(row, 4, 5)
    // if word then words_found.push(word) end
    
    // print("4 letter words =======")
    // if words_found.length == 0 then
    //   for i = 0 to 4
    //     word = word_at(row, i, 4)
    //     if dict.is_word(word) then words_found.push(word) end
    //     word = rev_word_at(row, 4, 4)
    //     if dict.is_word(word) then words_found.push(word) end
    //   end
    // end

    print("3 letter words =======")
    if words_found.length == 0 then
      for i = 0 to 4
        word = word_at(row, i, 3)
        print(word)
        print("Is word? " + dict.is_word(word))
        if dict.is_word(word) then add_if_new(words_found, word) end
        word = rev_word_at(row, 4, 3)
        print(word)
        print("Is word? " + dict.is_word(word))
        if dict.is_word(word) then add_if_new(words_found, word) end
      end
    end
    
    total = 0
    
    print("Computing score =======")
    print(words_found)
    for word in words_found
      ws = word.length // 1 point for each letter
      multiplier = 1
      if word.length == 5 then multiplier = 3 end
      if word.length == 4 then multiplier = 2 end
      total += ws*multiplier
    end
    
    print("score: " + total)
    print("words_found: " + words_found)
    
    total
  end
  
  drop = function(c, val)
    for i=r to 0
      if grid[i][c-1].char == " " then 
        grid[i][c-1].char = val
        _filled = _filled+1
        latest_score = compute_score(i, c-1)
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