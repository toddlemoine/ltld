Special = class
  constructor = function(x, y, value)  
    this.x = x
    this.y = y
    this.value = value
  end
  
  draw = function()
    screen.drawSprite(value, x, y)
  end
    
end


SpecialChooser = class
  constructor = function(x, y)
    this.x = x
    this.y = y
    this.w = 20
    this.h = 30
    this.choosing = false
    this.value = ""
    this.tick = 60
    this.duration = 0
    this.possibles = [
      specials.bomb,
      specials.boop
      ]
  end
  
  reset = function()
    value = ""
  end
    

  select = function()
    value = choose_random(possibles)
  end

  update = function()
  end
  
  draw = function()
    screen.drawRect(x, y, w, h)
    
    if value.length > 0 then
      new Special(x, y, value).draw()
    end
    
    if value == "" and not choosing then
      screen.fillRect(x, y, w, h, "tomato")
    end
    
    if selected_piece == -1 then
      local pos = object
        start_x = x - w/2
        end_x = x+w/2
        y = y+h/2+3
      end
      screen.drawLine(pos.start_x, pos.y, pos.end_x, pos.y, blue)
      screen.drawLine(pos.start_x, pos.y+1, pos.end_x, pos.y+1, blue)
    end
    
  
  end
end

choose_random = function(coll)
  coll[random.nextInt(coll.length)]  
end
