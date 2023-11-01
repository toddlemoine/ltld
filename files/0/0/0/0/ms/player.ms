Player = class
  score = 0
  pieces = []
  words = []

  constructor = function()
    this.fill()
  end
  
  add_points = function(points)
    score += points  
  end
  
  fill = function() 
    for i = 1 to max_player_pieces-pieces.length
      pieces.push(letter_bag.next())
    end
  end
  
  select = function(at)
    piece = pieces.removeAt(at)
    fill()
    piece
  end
  
end

