find_words_in_row = function(row, col_index)
  debug("================ Find words in row "+ col_index +" ================")
  debug(pick(row, "char"))
  
  local words_found = []
  
  for word_len = 5 to 3
    if words_found.length > 0 then
      break
    end
    
    for i = max(0, col_index-word_len-1) to min(col_index+word_len-1, row.length-1)
      if row[i].char == " " then continue end

      result = word_at(row, i, word_len)
      if dict.is_word(result.word) then
        add_if_new(words_found, result) 
      end

      result = word_at(reverse(row), i, word_len)
      if dict.is_word(result.word) then 
        add_if_new(words_found, result) 
      end
    end
  end
  
  words_found
end

find_words_in_col = function(coll, index)
  local words_found = []
  
  for word_len = 5 to 3
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
  debug("================ word_at "+ start_index + "/"+ word_len + " ================")

  result = object
    cells = []
    word = ""
    pos = []
  end
  
  letters = slice(coll, start_index, start_index+word_len-1)  
  
  debug(letters[0])

  if letters and has_empty_space(letters) == false then
    chars = []
    pos = []
    cells = []
    
    for l in letters
      debug("letter " + l.char)
      chars.push(l.char)
      cells.push(l)
      // if invert_order then
      //   pos.push(coll.length-i+start_index)
      // else
      //   pos.push(i+start_index)
      // end
    end
    
    result.cells = cells
    result.word = chars.join("")  
    result.pos = pos
  end
  
  result
end



add_if_new = function(coll, result)
  exists = false
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
  total = 0

  for word in words
    ws = word.length // 1 point for each letter
    multiplier = 1
    if word.length == 5 then multiplier = 3 end
    if word.length == 4 then multiplier = 2 end
    total += ws*multiplier
  end
  
  total  
end

