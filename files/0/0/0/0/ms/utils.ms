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

pick = function(coll, attr)
  result = []
  for obj in coll 
    result.push(obj[attr]) 
  end
  result
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

word_at = function(coll, start_index, word_len, invert_order=false)
  result = object
    word = ""
    pos = []
  end
  
  letters = slice(coll, start_index, start_index+word_len-1)  
  
  if letters and has_empty_space(letters) == false then
    chars = []
    pos = []
    
    for i = 0 to letters.length-1
      l = letters[i]
      chars.push(l.char.trim())
      if invert_order then
        pos.push(coll.length-i+start_index)
      else
        pos.push(i)
      end
    end
    
    result.word = chars.join("")  
    result.pos = pos
  end
  
  result
end

