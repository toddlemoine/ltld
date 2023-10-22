find_words_in_row = function(row, col_index)
  print("Scoring row ========= ")
  local words_found = []
  
  for word_len = 5 to 3
    if words_found.length > 0 then
      print("Breaking. words_found: " + words_found)
      break
    end
    
    print("- "+ word_len +" letter words")
    
    for i = max(0, col_index-word_len-1) to min(col_index+word_len-1, cols-1)
      print("- Row char: " + row[i].char)
      if row[i].char == " " then continue end
      word = word_at(row, i, word_len)
      print("- " + word)
      print("- Is word? " + dict.is_word(word))
      if dict.is_word(word) then 
        add_if_new(words_found, word) 
      end
      // word = rev_word_at(row, cols-1, word_len)
      // print(word)
      // print("Is word? " + dict.is_word(word))
      // if dict.is_word(word) then 
      //   add_if_new(words_found, word) 
      // end
    end

  end
  
  words_found
end


compute_score_for_words = function(words)
  print("Computing score for words " + words)  
  print(words)

  total = 0

  for word in words
    ws = word.length // 1 point for each letter
    multiplier = 1
    if word.length == 5 then multiplier = 3 end
    if word.length == 4 then multiplier = 2 end
    total += ws*multiplier
  end
  
  print("- score: " + total)
  
  total  
end

