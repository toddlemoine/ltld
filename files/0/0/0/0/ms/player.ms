Player = class
  pieces = []
  results = object end

  constructor = function()
    this.fill()
  end
  
  words = function()
    w = []
    for r in results
      if results[r] then w.push(r) end
    end
    w
  end
  
  word_count = function()
    local count = 0
    for x in results 
      if results[x] then count += 1 end
    end
    count
  end
  
  add_results = function(latest)
    for x in latest
      results[x.word] = x
    end
  end
  
  remove_results = function(removals)
    for x in removals
      results[x] = undefined
    end
  end
  
  score = function()
    local words = []
    for x in results
      if results[x] then words.push(x) end
    end
    compute_score_for_words(words)
  end
  
  
  fill = function() 
    for i = 1 to max_player_pieces-pieces.length
      pieces.push(letter_bag.next())
    end
  end
  
  select = function(at)
    piece = pieces.removeAt(at)
    fill()
    piece
  end
  
end

