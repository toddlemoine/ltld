
shuffle = function(coll)
  new_coll = []
  while (coll.length)
    idx = random.nextInt(coll.length)
    new_coll.push(coll.removeAt(idx))
  end
  new_coll
end

Letterbag = class
  constructor = function() 
    std = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("")
    pairs = "ER ES LL SS OO TH GE NN PP LY".split(" ")
    triplets = "ING ION IGE INE OPE".split(" ")
    this.bag = shuffle(std.concat(pairs).concat(triplets))
  end
  
  bag = []
  
  empty = function()
    bag.length == 0
  end
  
  next = function()
    bag.removeAt(random.nextInt(bag.length)).split("")
  end
  
end


