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
    this.curr = null
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
      this.curr = new Letter(target.char, cell_size, x, y)
      local target_col = min(target.col+2, cols-1)
      
      bump_target = board.drop_target_for(target_col)
      debug("bump target"+ bump_target.row +","+ bump_target.col)

      target.bump()
      tick = 0
      state = 1
    end
    
    if state == 1 then
      debug("updating current. CurrX:" + curr.x + ", targetX:"+ bump_target.x)
      
      if bump_target.x > curr.x then
        local new_x = curr.x-tick/10 
        debug("new x: " + new_x)
        this.curr.x = min(bump_target.x, new_x)
        tick -= 48
        // curr.update()
      else 
        debug("dropping current")
        this.curr.target = bump_target
        step = 1.5
      end
    end
    
    if step == 1.5 then
      if curr.at_target() then
        state = 2
        // board.remove_words_using_cell(target)        
      end
      curr.update()
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
