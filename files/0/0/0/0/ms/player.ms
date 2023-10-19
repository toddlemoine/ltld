Player = class
  score = 0
  pieces = []
  
  constructor = function()
    this.fill()
    print(pieces)
  end
  
  fill = function() 
    for i = 1 to max_player_letters-pieces.length
      pieces.push(letter_bag.next())
    end
  end
  
  draw_pieces = function()
    local total_chars = 0
    
    for piece in pieces
      total_chars += piece.length
    end

    local pieces_width = (total_chars+pieces.length-1)*cell_size
    local y = -90
    local x = -pieces_width/2

    for piece in pieces
      for char in piece
        new Letter(char, 15).draw(x, y)
        x += cell_size
      end
        x += cell_size

    end
  end
end
