reverse = function(coll)
  new_coll = []
  for i = coll.length - 1 to 0
    new_coll.push(coll[i])
  end
  new_coll
end