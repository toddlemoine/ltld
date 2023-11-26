white = "rgb(255,255,255)"
black = "rgb(0,0,0)"
red ="rgb(255,0,0)"
dark_red ="rgb(147,0,0)"
blue ="rgb(0,131,197)"
dark_gray ="rgb(25,25,25)"
dark_gray_100="rgb(48,48,48)"
light_gray ="rgb(223,223,223)"
med_gray ="rgb(141,141,141)"
gray = "rgb(118,118,118)"
game_bg = "rgb(255,255,255)"

// Modes
modes = object
  daily = "0"
  free = "1"
end

summary = object
  low = "Meh;Nice try;Whew;Try again;Mediocre!;(Shrug)".split(";")
  med = "Not shabby,Pretty good,Alright,Decent,Fair,Fine. It's fine.".split(",")
  high = "Boom!,Wicked!,Big Brain!,Awesome!,Fantastic!,Woah!,Incredible!,Wunderbar!,Stellar!,Impressive!".split(",")
end

font_score_text_size = 8
font_score_size = 14
font_board = "wilcoloftsanstreble" 
font_board_size = 11
font_game_over_size = 26
font_game_over_button_size = 10
font_flash_word_size = 24

// Offsets for font treatment in diff browsers
font_cell_offset = 1
font_game_over_offset = 0
font_game_over_button_text_offset = -1

urls = object
  feedback = "https://forms.gle/HqqL22N5oHKn76xj8"
  about = "/about.html"
end

defaults = object
  mode = modes.daily  
  theme = "light"
end

events = object
  play_again = "PlayAgain"
  share = "Share"
  restart = "Restart"
  switch_mode = "SwitchMode"
  toggle_theme = "ToggleTheme"
  toggle_default = "ToggleDefault"
  help_pushed = "HelpPushed"
  settings_pushed = "SettingsPushed"
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
    modal_bg = white
    modal_text = black
    move_control = black
    summary_button_text = white
    summary_bg = dark_gray
    summary_text = white
    copyright = light_gray
  end
  dark = object
    score_text = white
    game_bg = dark_gray
    cell_bg = dark_gray
    cell_border = med_gray
    cell_text = white
    cell_bg_disabled = light_gray
    cell_text_disabled = gray
    modal_bg = white
    modal_text = black
    move_control = white
    summary_button_text = white
    summary_bg = dark_gray
    summary_text = white
    copyright = dark_gray_100
  end
end