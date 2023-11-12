FlashWord = class
  constructor = function(word, y)
    this.word = word
    this.y = screen.height/2-40
    this.x = 0
    this.done = false
    this.tick = 1.5
    this.alpha = 0
  end
  
  update = function()
    tick += 0.055
    alpha = abs(cos(tick))
    done = tick >= 4.5
  end
  
  draw = function(delay)
    if not done then
      screen.setAlpha(alpha)
      shadow_text(word, x, y, font_flash_word_size, red)
      screen.setAlpha(1)
    end
  end
end