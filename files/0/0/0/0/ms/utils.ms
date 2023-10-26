concat = function()
  tmp = []
  for list in arguments
    tmp = tmp.concat(list)
  end
  tmp
end


reverse = function(coll)
  new_coll = []
  for i = coll.length-1 to 0
    new_coll.push(coll[i])
  end
  new_coll
end

map = function(coll, fn)
  new_coll = []
  index = 0
  for x in coll 
    new_coll.push(fn(x, index))
    index += 1
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

unique = function(coll1, coll2)
  tmp = []
  for c in coll2
    if not coll1.contains(c) then tmp.push(c) end
  end
  tmp
end

concat_unique = function(coll1, coll2)
  for c in coll2
    if coll1.contains(c) == false then coll1.push(c) end
  end
  coll1
end

has_empty_space = function(coll)
  for l in coll
    if l.char == " " then 
      return true
    end
  end
  false
end

shadow_text = function(text, x, y, size=12, color=black)
  screen.drawText(text, x+1, y-1, size, black)  
  screen.drawText(text, x, y, size, blue)    
end

