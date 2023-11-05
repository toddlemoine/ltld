white = "rgb(255,255,255)"
black = "rgb(0,0,0)"
yellow = "rgb(255,255,0)"
green = "rgb(80,197,22)"
red ="rgb(255,0,0)"
blue ="rgb(0,131,197)"
dark_gray ="rgb(25,25,25)"
light_gray ="rgb(223,223,223)"
gray ="rgb(118,118,118)"
game_bg = "rgb(255,255,255)"

font_score = "bitcell"
font_board = "bitcell"



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
  end
end