Player = class

  constructor = function()
    this.pieces = []
    this.results = object end
    this.daily = []
    this.fill()
  end
  
  summary_heading = function()
    _words = words()
    
    //1 points for each word
    //3 points for each daily
    // <5 points = low
    // 5-12 = med
    // 12+ = high    
    local points = _words.length

    if mode == modes.daily then
      for dw in daily_words
        if _words.contains(dw) then 
          points += 3
        end
      end
    end
    
    local coll = global.summary.low
    
    if points > 12 then
      coll = global.summary.high
    elsif points > 5 and points < 13 then
      coll = global.summary.med
    end
    coll[random.nextInt(coll.length)]
  end
  
  summary_desc = function()
    if letter_bag.empty() and morpheme_bag.empty() then
      return "You ran out of letters!"
    end
    ""
  end
  
  summary_daily = function()
    _words = words()
    local num_daily = 0
      for dw in daily_words
        if _words.contains(dw) then 
          num_daily += 1
        end
      end
    num_daily +" out of "+daily_words.length + " daily words"
  end
  
  summary = function()
    object
      heading = summary_heading()
      filled = round(board.percent_filled()*100)
      words = words().length
      points = score()
      daily = summary_daily()
      desc = summary_desc()
    end
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
    local current = reduce(pieces, function(acc, p)
      if specials_list.includes(p.join("")) then
        acc.specials.push(p)
      elsif p.length > 1 then
        acc.morphemes.push(p)
      else
        acc.pieces.push(p)
      end
      acc  
    end, object 
      specials = []
      morphemes = []
      pieces = []
    end)
    
    for i = 1 to max_player_pieces-pieces.length
      if current.specials.length < num_player_specials then
        current.specials.push(special_bag.next())
      elsif current.morphemes.length < num_player_morphemes then
        current.morphemes.push(morpheme_bag.next())
      else
        current.pieces.push(letter_bag.next())
      end
    end
    
    pieces = concat(current.pieces, current.morphemes, current.specials)
  end
  
  select = function(at)
    piece = pieces.removeAt(at)
    fill()
    piece
  end
  
end

