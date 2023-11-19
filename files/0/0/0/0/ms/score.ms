find_words_in_row = function(row, col_index)
  local words_found = []
  
  for word_len = 5 to 3
    // Take the longest word found.
    if words_found.length > 0 then
      break
    end
    
    for i = max(0, col_index-word_len-1) to min(col_index+word_len-1, row.length-1)
      if row[i].char == " " then continue end

      result = word_at(row, i, word_len)
      
      
      if dict.is_word(result.word) then
        words_found.push(result)
      end

      // debug("word at. start, word leng", i +","+ word_len)
      debug(pick(reverse(row), "char"))
      result = word_at(reverse(row), i-1, word_len)
      
      
      if dict.is_word(result.word) then 
        words_found.push(result)
      end
    end
  end

  scoreable_words = []
  
  for w in words_found
    if not board.results[w.word] then
      scoreable_words.push(w)
    end  
  end
  
  scoreable_words
end

find_words_in_col = function(coll, index)
  local words_found = []
  
  for word_len = 6 to 4
    if words_found.length > 0 then
      break
    end
    
    for i = min(index+word_len-1, coll.length-1) to max(0, index-word_len-1)
      if coll[i].char == " " then continue end
      
      result = word_at(coll, i, word_len)
      
      if dict.is_word(result.word) then
        add_if_new(words_found, result) 
      end

      result = word_at(reverse(coll), i-index, word_len)
      
      if dict.is_word(result.word) then 
        add_if_new(words_found, result) 
      end
    end
  end
  
  words_found   
end


word_at = function(coll, start_index, word_len, invert_order=false)

  result = object
    cells = []
    word = ""
    pos = []
  end
  
  letters = slice(coll, start_index, start_index+word_len-1)  
  // debug("letters", pick(letters, "char"))
  
  if letters and has_empty_space(letters) == false then
    chars = []
    pos = []
    cells = []
    
    for l in letters
      chars.push(l.char)
      cells.push(l)
    end
    
    result.cells = cells
    result.word = chars.join("")  
    result.pos = pos
  end
  
  result
end


add_if_new = function(coll, result)
  local exists = false
  for i in coll
    if i.word == result.word then 
      exists = true 
      break
    end
  end
  if not exists then
    coll.push(result)
  end
end


compute_score_for_words = function(words)
  local num_daily = 0
  total = 0

  for word in words
    ws = word.length // 1 point for each letter
    multiplier = 1
    if word.length == 6 then multiplier = 15 end
    if word.length == 5 then multiplier = 10 end
    if word.length == 4 then multiplier = 5 end
    total += ws*multiplier
    
    for dw in daily_words
      if word == dw then num_daily += 1 end
    end
    
  end

  if mode == modes.daily then  
    if num_daily > 0 then
      total += num_daily * 100
    end
  end
  
  total  
end

