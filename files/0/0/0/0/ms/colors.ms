white = "rgb(255,255,255)"
black = "rgb(0,0,0)"
yellow = "rgb(255,255,0)"
green = "rgb(80,197,22)"
red ="rgb(255,0,0)"
blue ="rgb(0,131,197)"
dark_gray ="rgb(25,25,25)"
light_gray ="rgb(223,223,223)"
med_gray ="rgb(141,141,141)"
gray = "rgb(118,118,118)"
game_bg = "rgb(255,255,255)"

// Modes
modes = object
  daily = "0"
  free = "1"
end

// font_score = "bitcell"
font_score_text_size = 8
font_score_size = 14
font_board = "wilcoloftsanstreble" // "interbold"
font_board_size = 11
font_game_over_size = 29
font_game_over_button_size = 10
font_flash_word_size = 24

// Offsets for font treatment in diff browsers
font_cell_offset = 1
font_game_over_offset = 0
font_game_over_button_text_offset = -1


defaults = object
  mode = modes.daily  
  theme = "light"
end

themes = object
  light = object
    score_text = black
    game_bg = white
    cell_bg = white
    cell_border = dark_gray
    cell_bg_disabled = light_gray
    cell_text_disabled = gray
    cell_text = black
    move_control = black
    game_over_color = blue
    game_over_button_text = white
  end
  dark = object
    score_text = white
    game_bg = dark_gray
    cell_bg = dark_gray
    cell_border = light_gray
    cell_text = white
    cell_bg_disabled = light_gray
    cell_text_disabled = gray
    move_control = white
    game_over_color = blue
    game_over_button_text = white
  end
end