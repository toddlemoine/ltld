Player = class
  pieces = []
  results = object end

  constructor = function()
    this.fill()
  end
  
  word_count = function()
    local count = 0
    for x in results count += 1 end
    count
  end
  
  add_results = function(latest)
    for x in latest
      results[x.word] = x
    end
  end
  
  score = function()
    local words = []
    for x in results
      words.push(x)
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

