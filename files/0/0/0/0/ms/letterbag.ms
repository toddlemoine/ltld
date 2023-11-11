letter_freq = object
  E = 0.111607
  A = 0.084966
  R = 0.075809
  I = 0.075448
  O = 0.071635
  T = 0.069509
  N = 0.066544
  S = 0.057351
  L = 0.054893
  C = 0.045388
  U = 0.036308
  D = 0.033844
  P = 0.031671
  M = 0.030129
  H = 0.030034
  G = 0.024705
  B = 0.02072
  F = 0.018121
  Y = 0.017779
  W = 0.012899
  K = 0.011016
  V = 0.010074
  X = 0.002902
  Z = 0.002722
  J = 0.001965
  Q = 0.001965
end

two_char_morphemes = ("ab ad bi de en ex in " +
"ob re se un " +
"al ar er ic " +
"st ty ve ze ly or ry th").split(" ")

three_char_morphemes = ("con non out per pre pro " +
"ary ate ent ial " +
"ism ist ity ive ize ory ous ure ture " +
"act cap leg min mod sta " +
"son sect pos ple org not nat ana bio dec dia " +
"eco epi geo gon oxy odo oid").split(" ")

morphemes = two_char_morphemes

shuffle = function(coll)
  new_coll = []
  while (coll.length)
    idx = random.nextInt(coll.length)
    new_coll.push(coll.removeAt(idx))
  end
  new_coll
end

fill_bag = function(size)
  local bag = []
  
  for letter in letter_freq
    freq = letter_freq[letter]
    count = max(1, round(size*freq))
    for i = 1 to count 
      bag.push(letter) 
    end
  end

  // Add Specials  
  local special_freq = max(1, round(size*letter_freq[special_freq_letter]*special_freq_modifier))
  
  local scount = 0
  for i = 1 to special_freq
    scount += 1
    bag.push(specials_list[random.nextInt(specials_list.length)])
  end
  
  debug("Specials added: " + scount +" (out of "+ size +")")
  
  // Add morphemes
  for i = 1 to size*morphemes_modifier
    bag.push(morphemes[random.nextInt(morphemes.length)].toUpperCase())
  end
  
  shuffle(bag)
end


DailyLetterbag = class
  
  constructor = function(raw_daily, _debug=false)
    this._debug = _debug
    this.bag = this.parse_raw(raw_daily)
  end
  
  parse_raw = function(raw_daily)
    debug("parsing" + raw_daily)
    local groups = raw_daily.bag.split(" ")
    local singles = groups[0]
    local morphemes = groups[1]
    local tmp = [] 
    
    dw = raw_daily.words.join("").split("")
    tmp = tmp.concat(dw)
    
    debug("Daily Word letters added", tmp)  
    
    tmp = tmp.concat(singles.split(""))
    
    for i=0 to morphemes.length-1 by 2
      pair = morphemes[i] + morphemes[i+1]
      tmp.push(pair)
    end
    
    // Add Specials  
    local size = tmp.length
    local special_freq = max(1, round(size*letter_freq[special_freq_letter]*special_freq_modifier))
    
    local scount = 0
    for i = 1 to special_freq
      scount += 1
      tmp.push(specials_list[random.nextInt(specials_list.length)])
    end
    
    debug("Specials added: " + scount +" (out of "+ size +")")
    
    if _debug then
      tmp
    else
      debug("shuffling")
      shuffle(tmp)
    end
  end
  
  empty = function()
    bag.length == 0
  end
  
  next = function(current_pieces)
    debug("Next from daily")
    local num_specials = 0
    
    for p in current_pieces
      if specials_list.includes(p.join("")) then
        num_specials += 1
      end
    end
    
    debug("number of specials: " + num_specials + " max: "+ max_specials)
    
    local allow_specials = num_specials < max_specials
    local drawn = ""
    
    if _debug then
      drawn = bag.removeAt(0)
    else
      drawn = bag.removeAt(random.nextInt(bag.length))
    end

    if specials_list.includes(drawn) and not allow_specials then 
      bag.insertAt(drawn, random.nextInt(bag.length))
      return this.next(current_pieces) 
    end

    drawn.split("")
  end  
  
end


Letterbag = class
  constructor = function(size)
    this.bag = fill_bag(size*2)
  end
  
  bag = []
  
  empty = function()
    bag.length == 0
  end
  
  next = function(current_pieces)
    debug("next from letterbag")
    local num_specials = 0
    
    for p in current_pieces
      if specials_list.includes(p.join("")) then
        num_specials += 1
      end
    end
    
    local allow_specials = num_specials < max_specials
    local drawn = bag.removeAt(random.nextInt(bag.length))

    if specials_list.includes(drawn) and not allow_specials then 
      bag.insertAt(drawn, random.nextInt(bag.length))
      return this.next(current_pieces) 
    end

    drawn.split("")
  end
  
end


