FlashWord = class
  constructor = function(word, y)
    this.word = word
    this.y = -160
    this.x = 0
    this.done = false
    this.tick = 0
  end
  
  update = function()
    tick += 1.5
    y += 0.5
    done = y>-130
  end
  
  draw = function(delay)
    if not done then
      screen.setAlpha(tick/60)
      shadow_text(word, x, y, 20, blue)
      screen.drawRect(0,0)
      screen.setAlpha(1)
    end
  end
end