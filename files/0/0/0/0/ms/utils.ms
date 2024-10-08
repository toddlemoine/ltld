concat = function()
  tmp = []
  for list in arguments
    tmp = tmp.concat(list)
  end
  tmp
end

count = function(coll, fn) 
  local x=0
  for c in coll
    if fn(c) then x+=1 end
  end
  x
end

reduce = function(coll, fn, acc)
  for c in coll
    acc = fn(acc, c)
  end
  acc
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

any = function(coll, fn)
  for x in coll
    if fn(x) then return true end
  end
  false
end

all = function(coll, fn)
  ok = true
  for x in coll
    if fn(x) == false then
      ok = false
      break
    end
  end
  ok
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
  screen.drawText(text, x+0.5, y-0.5, size, black)  
  screen.drawText(text, x, y, size, color)    
end

