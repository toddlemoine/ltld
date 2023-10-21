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

word_at = function(coll, startIndex, word_len)
  letters = slice(coll, startIndex, startIndex+word_len)  
  if letters then
    chars = []
    for l in letters chars.push(l.char.trim()) end
    return chars.join("")  
  end
end

rev_word_at = function(coll, startIndex, word_len)
  letters = slice(coll, startIndex, startIndex-word_len)  
  if letters then
    chars = []
    for l in letters chars.push(l.char.trim()) end
    return chars.join("")  
  end
end