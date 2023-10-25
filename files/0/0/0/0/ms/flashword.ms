FlashWord = class
  constructor = function(word, y)
    this.word = word
    this.y = 100
    this.x = 0
    this.done = false
    this.tick = 60
  end
  
  update = function()
    tick -= 1
    y += 1
    if y>screen.height/2 then done = true end
  end
  
  draw = function()
    if not this.done then
      screen.setAlpha(tick/60)
      screen.drawText(word, x, y, 20, black)
      screen.setAlpha(1)
    end
  end
end