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

two_char_morphemes = ("ab ad bi con de en ex in " +
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
  
  // Add Specials, same freq as T
  local bomb_freq = max(1, round(size*letter_freq.T))
  for i = 1 to bomb_freq
    bag.push("@")
  end
  
  for i = 1 to size
    bag.push(morphemes[random.nextInt(morphemes.length)].toUpperCase())
  end
  
  shuffle(bag)
end

Letterbag = class
  constructor = function(size)
    this.bag = fill_bag(size)
  end
  
  bag = []
  
  empty = function()
    bag.length == 0
  end
  
  next = function()
    bag.removeAt(random.nextInt(bag.length)).split("")
  end
  
end


