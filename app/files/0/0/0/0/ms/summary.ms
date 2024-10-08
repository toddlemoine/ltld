SummaryScreen = class
  constructor = function()
    this.x = 0
    this.y = 0
    this.w = screen.width
    this.h = screen.height
    this.tick = 0
    this.stage = 0
    this.buttons = object
      share = new Button("Share", 70, -screen.width/2 + 44, -screen.height/2+60)
      play_again = new Button("Play again?", 103, screen.width/2 - 60, -screen.height/2+60)
    end
    this.summary = current_player().summary()

  end
  
  update = function()
    
    if buttons.share.pressed() then 
      local webshare = copy_summary(board.toJSON(), this.summary)
      if not webshare then 
        buttons.share.text = "Copied!"
        after 1.5 seconds do
          buttons.share.text = "Share"
        end
      end
      return
    end
    if buttons.play_again.pressed() then 
      local props = object 
        mode = mode
      end
      track_event(events.play_again, props)
      return reset_game() 
    end
    
    tick = min(1, tick+.0325)

    if tick == 1 and stage == 0 then
      for i = 1 to 3
        after i*.75 seconds do
          stage = min(i, 3)
        end
      end
    end
  end
  
  draw = function()
    screen.setAlpha(tick)
    screen.fillRect(x, y, w, h, theme.summary_bg)
    screen.setAlpha(1)
    board.draw(board_y)
    draw_played_words(theme.summary_text)
    
    
    if stage >= 1 then
      local text = [summary.words + " words", summary.points + " points", summary.filled + "% filled"].join(", ")
      screen.drawText(text, 0, 138, 10, theme.summary_text)
    end

    if stage >= 2 then
      if mode == modes.daily then
        screen.drawText(summary.daily, 0, 119, 10, theme.summary_text)
      end
      screen.drawText(summary.desc, 0, 100, 10, theme.summary_text)
    end

    if stage >= 3 then
      local y = -84+font_game_over_offset
      local size = 36
      
      screen.drawText(summary.heading, 0, y-2, 24, black)
      screen.drawText(summary.heading, 0, y, 24, theme.summary_button_text)

      buttons.share.draw()
      buttons.play_again.draw()
    end
  
  end
end
