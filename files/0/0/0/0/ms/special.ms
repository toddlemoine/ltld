specials = object
  "@" = BombSpecial
  "<" = BumpLeftSpecial
  ">" = BumpRightSpecial
end

specials_list = "@<>".split("")

BumpLeftSpecial = class
  special = true
  
  constructor = function(x, y)
    this.w = cell_size
    this.h = cell_size
    this.x = x
    this.y = y
    this.target = null
    this.bump_target = null
    this.tick = 0
    this.state = 0 //0=default,1=bumping,1.5=dropping,2=done
    this.curr = null
  end
  
  done = function()
    state == 2
  end
  
  at_top = function()
    target == board.grid[0][target.col]
  end

  at_bottom = function()
    target.char == " " and target == board.grid[rows-1][target.col]
  end
  
  at_target = function()
    if target != null then
      return (y == target.y and x == target.x)
    end
    false
  end  
  
  update = function()
    if target != null and target != -1 then
      y = max(target.y, y+tick/10)
      tick -= 48
    end
    
    if state == 0 and at_target() then
      
      if at_bottom() then
        state = 2
        target.targeted = false
        target.explode()
        after 0.75 seconds do
          target.clear()
        end        
        return
      end
      
      local target_col = max(target.col, 1)
      
      if target_col == target.col then
        target.wiggle()
        after 0.5 seconds do
          target.off()
        end         
        state = 2
      else
        bump_target = board.drop_target_for(target_col)
        
        if bump_target == -1 then
          target.wiggle()
          after 0.5 seconds do
            target.off()
          end                   
          state = 2
        else
          curr = new Letter(target.char, cell_size, x, y)
          target.bump()
          tick = 0
          state = 1
        end
      end
      
    end
    
    if state == 1 then

      if bump_target.x < curr.x then
        local new_x = curr.x+tick/10 
        curr.x = max(bump_target.x, new_x)
        tick -= 48
      else 
        curr.target = bump_target
        step = 1.5
      end
    end
    
    if step == 1.5 then
      if curr.at_target() then
        board.remove_words_using_cell(target)
        state = 2
      end
      curr.update()
    end
  end  
  
  draw = function()
    if state == 0 then
      
      local sprite = "special_bump_left"
      
      screen.drawSprite(sprite, x, y, w, h)  
      
    elsif state < 2 then
      curr.draw()
    end
  end  
end


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
    this.state = 0 //0=default,1=bumping,1.5=dropping,2=done
    this.curr = null
  end
  
  done = function()
    state == 2
  end
  
  at_bottom = function()
    target.char == " " and target == board.grid[rows-1][target.col]
  end
  
  at_target = function()
    if target != null then
      return (y == target.y and x == target.x)
    end
    false
  end  
  
  update = function()
    if target != null then
      y = max(target.y, y+tick/10)
      tick -= 48
    end
    
    if state == 0 and at_target() then
      
      if at_bottom() then
        state = 2
        target.targeted = false
        target.explode()
        after 0.75 seconds do
          target.clear()
        end      
      end
      
      local letter_target_col = min(target.col+1, cols-1)
    
      if letter_target_col == target.col then
        target.wiggle()
        after 0.5 seconds do
          target.off()
        end         
        state = 2
      else
        bump_target = board.drop_target_for(letter_target_col+1)
      
        if bump_target == -1 then
          target.wiggle()
          after 0.5 seconds do
            target.off()
          end         
          state = 2
        else
          this.curr = new Letter(target.char, cell_size, x, y)
          target.bump()
          tick = 0
          state = 1
        end        
      end
    end
    
    if state == 1 then
      if bump_target == -1 then
        target.targeted = false
        target.explode()
        after 0.75 seconds do
          target.clear()
        end        
        step = 2 
      end
      
      if bump_target.x > curr.x then
        local new_x = curr.x-tick/10 
        this.curr.x = min(bump_target.x, new_x)
        tick -= 48
      else 
        this.curr.target = bump_target
        step = 1.5
      end
    end
    
    if step == 1.5 then
      if curr.at_target() then
        board.remove_words_using_cell(target)
        state = 2
      end
      curr.update()
    end
  end  
  
  draw = function()
    if state == 0 then
      local sprite = "special_bump_right"
      screen.drawSprite(sprite, x, y, w, h)  
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
    if target != null then
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


