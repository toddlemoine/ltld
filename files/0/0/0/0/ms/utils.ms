reverse = function(coll)
  new_coll = []
  for i = coll.length - 1 to 0
    new_coll.push(coll[i])
  end
  new_coll
end

slice = function(coll, startIndex, endIndex)
  if endIndex > coll.length-1 or startIndex > coll.length -1 then 
    return undefined 
  end
  c = []
  for i = startIndex to endIndex
    c.push(coll[i])
  end
  c
end

add_if_new = function(coll, word)
  if coll.contains(word) == false then
    coll.push(word)
  end
end

concat_unique = function(coll1, coll2)
  for c in coll2
    if coll1.contains(c) == false then coll1.push(c) end
  end
  coll1
end

has_empty_space = function(coll)
  for l in letters
    if l.char == " " then 
      return true
    end
  end
  false
end

word_at = function(coll, startIndex, word_len)
  letters = slice(coll, startIndex, startIndex+word_len-1)  
  if letters and has_empty_space(letters) == false then
    chars = []
    for l in letters chars.push(l.char.trim()) end
    return chars.join("")  
  end
end

rev_word_at = function(coll, startIndex, word_len)
  letters = slice(coll, startIndex, startIndex-word_len-1)  
  if letters and has_empty_space(letters) == false then
    chars = []
    for l in letters chars.push(l.char.trim()) end
    return chars.join("")  
  end
end