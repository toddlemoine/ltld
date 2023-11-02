BumpRightSpecial = class
  special = true
  constructor = function(x, y)
    this.w = cell_size
    this.h = cell_size
    this.x = x
    this.y = y
    this.target = null
    this.bump_target = null
    this.tick = 0
    this.enabled = true
    this.state = 0 //0=default,1=bumping,1.5=dropping,2=done
  end
  
  done = function()
    state == 2
  end
  
  at_target = function()
    if target != null then
      return (y == target.y and x == target.x)
    end
    false
  end  
  
  update = function()
    if enabled and target != null then
      y = max(target.y, y+tick/10)
      tick -= 48
    end
    
    if state == 0 and at_target() then
      debug("bumpright at target. Col:" + target.col)
      // this.letter = new Letter(target.char, cell_size, x, y)
      curr = new Current(x, y)
      curr.col = min(target.col+2, cols-1)
      curr.set_pieces([target.char])
      
      bump_target = board.drop_target_for(target.col+2)
      debug("bump target"+ bump_target.row +","+ bump_target.col)

      target.bump_right()
      tick = 0
      state = 1
    end
    
    if state == 1 and not curr.dropping then
      debug("updating current. CurrX:" + curr.x + ", targetX:"+ bump_target.x)
      
      if bump_target.x > curr.x then
        curr.x = min(bump_target.x, curr.x+tick/10) 
        tick += 48
        curr.update()
        
      // elsif bump_target.x < curr.x then
      //   curr.x = max(bump_target.x, curr.x-tick/10) 
      else 
        debug("dropping current")
        curr.target = bump_target
        curr.drop()
      end
    end
    
    
    if curr.dropping then
      curr.update()
    elsif curr.done then
      // board.remove_words_using_cell(target)        
      state = 2
    end
  end  
  
  draw = function()
    if state == 0 then
      screen.drawSprite("special_bump_right", x, y, w, h)
    elsif state < 2 then
      curr.draw()
    end
  end  
end



BombSpecial = class
  special = true
  
  constructor = function(x, y)  
    this.w = cell_size
    this.h = cell_size
    this.x = x
    this.y = y
    this.target = null
    this.tick = 0
    this.enabled = true
    this.state = 0 //0=default,1=exploded,2=done
  end
  
  done = function()
    state == 2
  end
  
  at_target = function()
    if target != null then
      return (y == target.y and x == target.x)
    end
    false
  end  
  
  update = function()
    if enabled and target != null then
      y = max(target.y, y+tick/10)
      tick -= 48
    end
    
    if state == 0 and at_target() then
      target.explode()
      state = 1
      
      after 0.75 seconds do
        board.remove_words_using_cell(target)        
        target.clear()
        state = 2
      end
        
    end
    
  end  
  
  draw = function()
    if state == 0 then
      screen.drawSprite("special_bomb", x, y, w, h)
    end
  end
    
end
