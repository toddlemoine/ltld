draw_controls = function()
  y = -(screen.height/2)+30
  draw_move_left()
  draw_move_right()
  // Rotate
  
  draw_select()  
end

draw_select = function()
  local w = 40
  screen.fillRound(screen.width/2-35, y-2, w, w, black)
  screen.fillRound(screen.width/2-35, y, w, w, red)
end


draw_move_left = function()
  local w = 40
  local pad = 10
  
  local c = object
    x1 = -screen.width/2+w+pad
    y1 = -(screen.height/2)+w+pad
  end
  
  c.x2 = c.x1 - w
  c.y2 = c.y1 - w/2
  c.x3 = c.x1
  c.y3 = c.y2 - w/2
  
  screen.fillPolygon(c.x1, c.y1, c.x2, c.y2, c.x3, c.y3, black)

end

draw_move_right = function()
  local w = 40
  local pad = 10
  
  local c = object
    x1 = -screen.width/2+w+pad*2
    y1 = -(screen.height/2)+w+pad
  end
  
  c.x2 = c.x1 + w
  c.y2 = c.y1 - w/2
  c.x3 = c.x1 
  c.y3 = c.y1 - w
  
  screen.fillPolygon(c.x1, c.y1, c.x2, c.y2, c.x3, c.y3, black)

end