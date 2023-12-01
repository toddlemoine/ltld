</script><script id="code" type="text/x-microscript">


function()
Board = class 
  
  constructor = function(r, c, cell_size)
    this.c = c
    this.r = r
    this.cell_size = cell_size
    this.grid = []
    this.latest_results = []
    this.latest_removed_results = []
    this.results = object end
    
    for i=0 to r-1
      local row = []
      for j=0 to c-1
        row.push(new Cell(j, i, cell_size))
      end
      this.grid.push(row)
    end
  end
  
  toJSON = function()
    local result = []
    for row in grid
      local r = []
      for cell in row
        r.push(cell.toJSON())
      end
      result.push(r)
    end
    result
  end
  
  percent_filled = function()
    num_selected = 0
    for r in grid
      for c in r
        if c.selected then num_selected += 1 end
      end
    end
    num_selected/(this.c*this.r)
  end
  
  update = function()
    for r in results
      for cell in results[r].cells
        cell.on()
      end
    end
  end
  
  words_used = function()
    local words = []
    for key in results
      if results[key] then 
        words.push(key)
      end
    end
    words
  end
  
  filled = function()
    local count = 0
    for row in grid
      for col in row
        if col.char != " " then count += 1 end
      end
    end
    count == c*r
  end
  
  reset_score = function()
    latest_results = []
    latest_removed_results = []
  end
  
  column_is_open = function(col_index)
    grid[0][col_index].char == " "
  end
  
  column_to_row = function(col_index)
    cells = []
    for r in grid
      cells.push(r[col_index])
    end
    cells
  end
  
  diagonal_left = function(row_index, col_index)
    cells = []
    
    // find the start
    pos = object
      r = row_index
      c = col_index
    end
  
    done = false
    
    while not done
      next = grid[pos.r][pos.c]
      if not next then
        done = true
      else
        cells.push(next)
        pos.r = pos.r+1
        pos.c = pos.c-1
      end
    end
    
    cells = reverse(cells)

    // find the end
    done = false
    
    pos.r = row_index-1
    pos.c = col_index+1
    
    while not done
      next = grid[pos.r][pos.c]
      if not next then
        done = true
      else
        cells.push(next)
        pos.r = pos.r-1
        pos.c = pos.c+1
      end
    end
    
    cells
  end
  
  diagonal_right = function(row_index, col_index)
    cells = []
    
    // find the start
    pos = object
      r = row_index
      c = col_index
    end
  
    done = false
    
    while not done
      next = grid[pos.r][pos.c]
      if not next then
        done = true
      else
        cells.push(next)
        pos.r = pos.r-1
        pos.c = pos.c-1
      end
    end
    
    cells = reverse(cells)

    // find the end
    done = false
    
    pos.r = row_index+1
    pos.c = col_index+1
    
    while not done
      next = grid[pos.r][pos.c]
      if not next then
        done = true
      else
        cells.push(next)
        pos.r = pos.r+1
        pos.c = pos.c+1
      end
    end
    
    cells
  end
  
  score_cell = function(cell)
    // Score for row
    local _results = find_words_in_row(grid[cell.row], cell.col)

    // col
    _results = _results.concat(find_words_in_col(column_to_row(cell.col), cell.row))

    // diag left
    _results = _results.concat(find_words_in_row(diagonal_left(cell.row, cell.col), cell.col))

    // diag right
    _results = _results.concat(find_words_in_row(diagonal_right(cell.row, cell.col), cell.col))
    
    // Set on the instance
    latest_results = add_results(_results)
    
    current_player().add_results(latest_results)
    
    for w in pick(latest_results, "word")
      flash_words.push(new FlashWord(w, 90))
    end
    
    // TODO: Move this to an update somewhere
    // highlight cells
    for r in latest_results
      for rc in r.cells rc.on() end
    end        
    
  end
  
  remove_words_using_cell = function(cell)
    for r in results
      if any(results[r].cells, function(c) 
        c.row == cell.row and c.col == cell.col
      end) then
        // Remove from results
        for c in results[r].cells
          c.off()
        end
        results[r] = undefined
        latest_removed_results.push(r)
      end
    end

    current_player().remove_results(latest_removed_results)
  end
  
  add_results = function(latest)
    added = []
    for result in latest
      if not results[result.word] then
        results[result.word] = result
        added.push(result)
      end
    end
    added
  end
  
  drop_target_for_special = function(c)
    for i=0 to r-1
      curr_cell = grid[i][c-1]
      if curr_cell.targeted then
        return curr_cell
      end
    end
    // Column is empty; drop on bottom-most cell
    grid[r-1][c-1]
  end
  
  drop_target_for = function(c)
    for i=r-1 to 0
      curr_cell = grid[i][c-1]
      
      if not curr_cell.targeted then 
        curr_cell.targeted = true
        return curr_cell
      end
    end
    debug("no drop target found; -1")
    // No available target
    -1
  end
  
  draw = function(y)
    local x_offset = cell_size*c/2-cell_size/2

    for i=0 to grid.length-1
      for j=0 to grid[i].length-1
        grid[i][j].x = -(x_offset-cell_size*j)
        grid[i][j].y = y-cell_size*i
        grid[i][j].draw()
      end
    end
    
  end

end


end()



function()
Cell = class
  constructor = function(col, row, size, char=" ")
    this.col = col
    this.row = row
    this.size = size
    this.char = char
    this.x = 0
    this.y = 0
    this.targeted = false
    this.tick = 0
    // 0=normal, 1=selected, 2=exploding, 3=wiggling
    this.state = 0 
    this.selected = false
  end
  
  toJSON = function()
    object
      char = char
      selected = selected
    end
  end
  
  clear = function()
    state = 0
    char = " "
    targeted = false
  end
  
  on = function()
    selected = true
  end
  
  off = function()
    selected = false
  end
  
  calm = function()
    state = 0
  end
  
  explode = function()
    char = " "
    state = 2
  end
  
  wiggle = function()
    state = 3
  end

  bump = function()
    char = " "
    targeted = null
    state = 0
  end
  
  draw = function()
    local colors = object
      bg = theme.cell_bg
      text = theme.cell_text
      border = theme.cell_border
    end

    if selected then
      colors.bg = red
      colors.text = white
    end

    screen.drawRect(x, y, size, size, colors.border)
    screen.fillRect(x, y, size-1, size-1, colors.bg)
    text_x = x
    
    if state == 3 then
      text_x = x + cos(tick)
      tick += .75
    end
    
    screen.drawText(char, text_x, y-font_cell_offset, font_board_size, colors.text)
    
    if state == 2 then
      screen.drawSprite("explosion", x, y, size, size)
    end
    
    
  end

end

end()



function()
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
  finished = "Finished"
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
end()



function()
MoveControl = class 
  constructor = function(x, y, invert)
    this.x = x
    this.y = y
    this.w = 35
    this.invert = invert
  end
  
  clone = function()
    new MoveControl(x, y, invert)
  end
  
  hovered = function()
    local in_y = touch.y > y-w and touch.y < y
    if invert then 
      return in_y and touch.x > x-w and touch.x < x 
    else
      return in_y and touch.x > x and touch.x < x+w 
    end
  end
  
  pressed = function()
    hovered() and touch.release
  end
  
  draw = function()
    local c = object
      x1 = x
      y1 = y
    end
    
    if not invert then
      c.x2 = c.x1 + w
    else
      c.x2 = c.x1 - w
    end
    
    c.y2 = c.y1 - w/2
    c.x3 = c.x1 
    c.y3 = c.y1 - w
    
    local color = theme.move_control
    local pressed = hovered() and touch.touching
    if pressed then color = gray end
    if pressed then
      screen.fillPolygon(c.x1, c.y1-2, c.x2, c.y2-2, c.x3, c.y3-2, gray)
    else
      screen.fillPolygon(c.x1, c.y1-2, c.x2, c.y2-2, c.x3, c.y3-2, black)
      screen.fillPolygon(c.x1, c.y1, c.x2, c.y2, c.x3, c.y3, gray)      
    end
  
  end
  
end

SelectControl = class
  constructor = function(x, y, color)
    this.x = x
    this.y = y
    this.w = 35
    this.color = color
  end
  
  clone = function()
    new SelectControl(x, y, color)
  end
  
  hovered = function()
    touch.y > y-w/2 and touch.y < y+w/2 and touch.x > x-w/2 and touch.x < x+w/2
  end
  
  pressed = function()
    hovered() and touch.release
  end  
  
  draw = function()
    local pressed = hovered() and touch.touching
    
    if pressed then
      screen.fillRound(x, y-2, w, w, color)
    else
      screen.fillRound(x, y-2, w, w, black)
      screen.fillRound(x, y, w, w, color)
    end
    
  end
end

RotateControl = class extends SelectControl
  constructor = function(x, y, color)
    super(x, y, color)
  end
  draw = function()
    super()
  end
end


PauseControl = class
  constructor = function(x, y, text, color = gray)
    this.x = x
    this.y = y
    this.w = 15
    this.h = 8
    this.r = 25
    this.text = text
    this.color = color
  end
  
  hovered = function()
    touch.y > y-w/2 and touch.y < y+w/2 and touch.x > x-w/2 and touch.x < x+w/2
  end
  
  pressed = function()
    hovered() and touch.release
  end  
  
  draw = function()
    local pressed = hovered() and touch.touching
    
    if pressed then
      screen.fillRoundRect(x, y-2, w, h, r, color)
    else
      screen.fillRoundRect(x, y-2, w, h, r, black)
      screen.fillRoundRect(x, y, w, h, r, color)
    end
    
    screen.drawText(text, x, y+h+2, 6)
    
  end
end


AboutLink = class extends Link
  constructor = function(text, x, y, font_size, color)
    super(text, x, y, font_size, color)
  end
  update = function()
    if pressed() then
      click_link("about")
    end
  end
end



end()



function()
Current = class
  constructor = function(x, y)
    this.x = x
    this.y = y
    this.pos = 1
    this.col = round(cols/2)
    this.cells = []
    this.dropping = false
    this.tick = 60
    this.done = false
    this.allow_rotate = true
  end
  
  is_pending = function() cells.length == 0 end
  
  set_pieces = function(letters)
    cells = []
    
    for letter in letters
      if letter == "@" then 
        cells.push(new BombSpecial(0, y))
        allow_rotate = false
      elsif letter == "<" then 
        cells.push(new BumpLeftSpecial(0, y))
        allow_rotate = false
      elsif letter == ">" then 
        cells.push(new BumpRightSpecial(0, y))
        allow_rotate = false
      else
        cells.push(new Letter(letter, cell_size, 0, y))
        allow_rotate = true
      end
    end
    
    // layout the new cells
    update()
  end  
  
  move_left = function()
    if col > 1 then
      if pos == 3 then
        col = max(col-1, cells.length)
      else
        col = max(col-1, 1)
      end
    end
  end
  
  move_right = function()
    if col < cols then
      if pos == 1 then
        col = min(col+1, cols-cells.length+1)
      else
        col = min(col+1, cols)
      end
    end
  end
  
  can_rotate = function()
    if pos == 4 then
      return col+cells.length <= cols+1
    elsif pos == 2 then
      return col >= cells.length
    end
    true
  end
  
  can_rotate_ccw = function()
    if pos == 4 then
      return col >= cells.length
    elsif pos == 2 then
      return col+cells.length <= cols+1
    end
    true
  end  
  
  rotate_ccw = function()
    if not can_rotate_ccw() then return end
    
    if pos == 1 then 
      pos = 4
    else 
      pos -= 1
    end    
  end
  
  rotate = function()
    if not can_rotate() then return end
    
    if pos == 4 then 
      pos = 1
    else 
      pos += 1
    end
  end
  
  drop = function()
    if any(cells, function(cell) cell.enabled end) then
      dropping = true
      if pos == 1 then drop_horiz(cells)
      elsif pos == 2 then drop_vert(reverse(cells))
      elsif pos == 3 then drop_horiz(cells, true)
      elsif pos == 4 then drop_vert(cells)
      end
    else
      debug("cannot drop")
    end
  end
  
  drop_vert = function(coll)
    for letter in coll
      if letter.special then
        letter.target = board.drop_target_for_special(col+count)
      else
        letter.target = board.drop_target_for(col, letter.char)
      end
    end
  end
  
  drop_horiz = function(coll, invert=false)
    local count = 0
    for letter in coll
      if invert then
        letter.target = board.drop_target_for(col-count, letter.char)
      else
        if letter.special then
          letter.target = board.drop_target_for_special(col+count)
        else
          letter.target = board.drop_target_for(col+count, letter.char)
        end
      end
      count += 1
    end
  end
  
  update_vert = function(coll, invert=false)
    
    local count = 0
  
    for letter in coll
      if not dropping then
        local x_offset = cell_size*cols/2-cell_size/2
        local y_offset = cell_size*count
        letter.x = x_offset-cell_size*(cols-col)
        letter.y = y - y_offset
        
        if not letter.special then
          letter.enabled = board.column_is_open(col-1)
        else
          letter.set_enabled(col-1)
        end
                
        if invert and count > 0 then
          letter.y = y + y_offset
        end
        
      end
      
      letter.update()
      count += 1
    end  
  end
  
  update_horiz = function(coll, invert=false)
    local count = 0
  
    for letter in coll
      if not dropping then
        local x_offset = (cell_size*cols/2-cell_size/2)

        letter.x = x_offset-cell_size*(cols-col-count)
        letter.y = y
        
        if not letter.special then
          letter.enabled = board.column_is_open(col-1)
        end
                
        if invert then
          if count > 0 then
            letter.x = x_offset-cell_size*(cols-col+count)
            letter.enabled = board.column_is_open(col-count-1)
          end
        else
          if count > 0 then
            letter.enabled = board.column_is_open(col+count-1)
          end
        end
      end
      
      letter.update()
      count += 1
    end    
  end
  
  update = function()
    if pos == 1 then update_horiz(cells)
      elsif pos == 2 then update_vert(cells)
      elsif pos == 3 then update_horiz(cells, true)
      elsif pos == 4 then update_vert(cells, true)
      end      
    
    if dropping then
      all_done = all(cells, function(cell) cell.done() end)
      
      if all_done then 
        cells = [] 
        dropping = false
        done = true
      end
      
    end
  end
  
  draw = function()
    for cell in cells 
      cell.draw()
    end
  end
end


end()



function()
debug = function()
  if not DEBUGGER then return end
  for arg in arguments
    if arg.type == "list" then 
      // for x in arg debug(x) end
      print(arg)
    else
      print(arg)
    end
  end
end
end()



function()
Dictionary = class
  index = object end

  constructor = function()
    add_words(four_letter.concat(five_letter.concat(six_letter.concat(custom))))
  end
  
  add_words = function(words)
    for w in words
      key = w.substring(0,3).toLowerCase()
      if index[key] == 0 then
        index[key] = []
      end
      index[key].push(w.toLowerCase())    
    end
  end
  
  is_word = function(word)
    key = word.substring(0,3)
    if key then key = key.toLowerCase() end
    if index[key] then
      return index[key].contains(word.toLowerCase())
    end
    false
  end
end

four_letter = "aahs abet able ably abut aced aces ache achy acid acme acne acre acts acyl adds adze afar afro agar aged ages agin agog ague ahas ahem ahoy aide aids ails aims airs airy ajar akin alas albs alef ales alga ally alms aloe alps also alto alum ambo amen amid amok amps amyl anal ands anew anon ante ants anus aped aper apes apex apps aqua arch arcs area ares aria arid aril arks arms army arts arty aryl ashs ashy asks asps atom atop aunt aura auto aven aver avid avow away awed awes awls awns awny awol awry axed axel axes axis axle axon ayes ayin azym baas babe baby back bade bags baht bail bait bake bald bale balk ball balm band bane bang bank bans barb bard bare barf bark barm barn bars base bash bask bass bath bats baud bawd bawl bays bead beak beam bean bear beat beau beds beef been beep beer bees beet begs bell belt bend bene bens bent berk berm best beta beth bets bevy bias bibs bide bids bike bile bilk bill bind bins bios bird birr bite bits bitt blab blah blat bleb bled blew blip blob bloc blog blot blow blue blur boar boas boat bobs bode body bogs boil bold bole boll bolt bomb bond bone bonk bony book boom boon boor boos boot bops bore born boss both bots bout bowl bows boxy boys brad brag bran bras brat bray bred brew brie brim brin bris brow brux bubo buck buds buff bugs buhl buhr bulb bulk bull bump bums bunk buns bunt buoy burl burn burp burr burs bury bush busk bust busy buts butt buys buzz byes byte cabs cads cafe cage cake calf call calm calx came camp cams cane cans cant cape caps card care carp cars cart case cash cask cast cats cave caws ceca cede cedi cees cell celt cent cere chad chap char chat chef chew chic chin chip chis chiv chop chow chub chug chum cite city clad clag clan clap claw clay clef clip clod clog clop clot cloy club clue coak coal coat coax cobs cock coda code cods coed cogs coho coif coil coin cola cold cole colt coma comb come cone conk cons cook cool coop coos coot cope cops copy cord core cork corm corn cost cosy cots coup cove cowl cows coys cozy crab crag cram crap crew crib crop crow crud crux cube cubs cuds cued cues cuff cull culm cult cups curb curd cure curl curs curt cusp cuss cute cuts cwms cyan cyma cyme cyst czar dabs dado dads daft dame damn damp dams dank dare dark darn dart dash data date daub dawn days daze dead deaf deal dean dear debt deck deed deem deep deer dees deet deft defy deil dele delf deli dell deme demo demy dene dens dent deny dere derm desk deva dews dewy deys dhow dial dibs dice died dies diet digs dill dime dims dine ding dins dint dips dire dirt disc dish disk ditz diva dive dock dodo doer does doff doge dogs dojo dole doll dolt dome done dons doom door dope dork dorm dorr dors dose dote doth dots doty dove down doxx doxy doze dozy drab drag dram draw dray dreg drew drey drib drip drop drub drug drum dual dubs duck duct dude duds duel dues duet duff duke dull duly dumb dump dune dung dunk duos dupe dusk dust duty dyad dyed dyer dyes dyne dzos each earl earn ears ease east easy eats eave ebbs echo ecru eddy edge edgy edit eeks eels eely eery effs eggs eggy egos eked eker ekes elix elks ells elms else emir emit emus ends enol envy eons epic eras ergo ergs eros etas etch euro even ever eves evil ewer ewes exam exes exit exon expo eyed eyes face fact fade fads fail fain fair fake fall fame fang fans fare farm fast fate fats faun faux fave fawn faze fear feat feds feed feel fees feet fell felt fend fens fern feta feud fibs figs file fill film find fine fink fins fire firm firs fish fist fits five fizz flab flag flan flap flat flaw flax flay flea fled flee flew flex flip flit floe flog flop flow flox flub flue flux foal foam fobs foci foes fogs fogy fohs foil fold folk fond font food fool foot fops fora forb fore fork form fort foul four fowl foxy fozy fray free fret friz frog from fuel fuff fuki full fume fumy fund funk furl furs fury fuse fuss fuze fuzz gabs gaff gaga gage gags gain gait gala gale gall gals game gang gaol gape gaps garb gash gasp gate gave gawk gawp gaze gear geek gees geld gell gels gems gene gent germ gets gift gigs gild gill gilt gimp gins gird girl girn gist give glad glee glen glia glib glob glow glue glug glum glut gnar gnat gnaw gnus goad goal goat gobs goby gods goer goes goji gold golf gone gong good goof goon goop goos gore gory gosh goth gout gown grab gram gray grew grey grid grim grin grip grit grow grub guck guff gulf gull gulp gums gunk guns guru gush gust guts guys gyms gyne gyps gyre gyro hack hags hail hair half hall halo halt hams hand hang haps hard hare hark harm harp hash hasp hate hath hats haul have hawk haws hays haze hazy head heal heap hear heat heck heed heel heir held hell helm help heme hems hens herb herd here hero hers heth hewn hews hick hics hide high hike hill hilt hind hint hips hire hiss hits hive hoar hoax hobo hoed hoer hoes hogs hold hole holy home hone honk hood hoof hook hoop hoot hope hops horn horo hose host hots hour howl hows hubs hued hues huff huge hugs huhs hula hulk hull hump hums hung hunk hunt hurl hurt hush husk huts hymn hype hypo iamb ibex ibis iced icer ices icky icon idea ides idle idly idol iffy ilea ilka ilks ills imam imps inch inks inky inns into ions iota ipad ired ires irid iris irks iron isle isms itch item jabs jack jade jags jail jali jamb jams jars java jaws jays jazz jean jeep jeer jeli jell jerk jest jets jibe jigs jilt jink jinx jive jivy jobs jock jogs join joke jolt josh jots jowl joys judo jugs juke july jump june junk jury just jute juts kale kaon kaph kata kats kava kays keek keel keen keep kegs kelp keps kept kern keys kick kids kill kiln kilt kina kind kine king kink kips kiss kite kits kiwi knar knee knew knit knob knot know knur kook kudu kuna kyak kyat labs lace lack lacy lade lads lady lags laid lain lair lake lamb lame lamp land lane lank laps lard lari lark lash lass last late laud lava lave lawn laws lays laze lazy lead leaf leak lean leap lear leas lede leek leer lees left legs leks lend lens lent lept less lest lets leus levs levy lewd liar lice lick lids lied lien lier lies lieu life lift like lilt lily limb lime limn limo limp limy line link lint lion lips lira lire lirk lisp list lite live load loaf loam loan lobe lobs loch loci lock loco lode loft logo logs loin loll lone long look loom loon loop loos loot lope lops lord lore lory lose loss lost loti lots loud lout love lows luau lube luck luff luge lugs lull lump lung lure lurk lush lust lute lynx lyre mace mach made mage magi maid mail maim main make male mall malt mama mane mans many maps mara mare mark marl mars mart mash mask mass mast mate math mats matt maul maws mayo mays maze mead meal mean meat meek meet meld melt meme memo mend mens menu meow mere mesa mesh mess mews mica mice midi miff mild mile milk mill mils mime mind mine mini mink mint minx mire miss mist mite mitt moan moat mobs mock mode mods moho mold mole molt moms monk mood moon moor moos moot mope mops more moss most moth move mown mows much muck muff mugs mule mull mums muon murk muse mush musk must mute mutt myna myth nabs nags nail name nand nape naps naut nave navy nays nazi neap near neat neck need neon nerd nest nets nevi news newt next nibs nice nick nigh nils nine nips nits nobs nock node nods noel none noon nope norm nose nosy note noun nova nubs nude nuke null numb nuns nuts oafs oaks oars oath oats obey oboe octo odds odes odor offs ogle ogre ohms oils oily oink okay okra olea oleo omen omit omni once ones only onto onus onyx oohs ooid oops ooze oozy opal open opts oral orbs orca ores oryx ouch ours oust outs ouzo oval oven over ovum owed ower owes owls owly owns oxea oxen oxes pace pack pact pads page paid pail pain pair pale pall palm palp pals pane pang pans pant papa paps pare park pars part pass past pate path pats pave pawn paws pays peak peal pear peas peat peck peek peel peep peer pegs pelf pelt pend pens pent peon pepo peps perk perm pert peso pest pets pews phis phiz phub pica pick pied pier pies pigs pike pile pili pill pimp pine ping pink pins pint pion pipe pips pita pith pits pity pius plan play plea pleb pled plod plop plot plow ploy plug plum plus pock pods poem poet pogo poke poky pole poll polo pomp pond pony pooh pool poop poor pope pops pore pork porn port pose posh post posy pots pouf pour pout poxy pram pray prep prey prim prod prom prop pros prow psis pubs puce puck puff pugs puke pull pulp puma pump punk puns punt puny pupa pups pure purr push puts putt pyre qadi qaid qats qoph quad quay quid quin quip quit quiz race rack racy raft rage rags raid rail rain rake rami ramp rams rand rang rank rant rape raps rapt rare rash rasp rate rats rave raws rays raze razz read reak real ream reap rear redo reds reed reef reek reel refs rein rely rend rent repo resh rest revs rhos rial ribs rice rich rick ride rids riel rife riff rift rigs rile rill rily rime rims rind ring rink riot ripe rips rise risk rite rive road roam roan roar robe robs rock rode rods roes roil role roll romp rood roof rook room root rope ropy rose rosy rote rots roue rout rove rows rubs ruby rude rued rues ruff rugs ruin rule rums rune rung runs runt ruse rush rust rute ruts sack sacs safe saga sage sags sagy said sail sake saki sale salt same sand sane sang sank saps sard sari sash sass sate save sawn saws says scab scam scan scar scat scot scry scud scum scuz seal seam sear seas seat sect seed seek seem seen seep seer sees self sell seme send sent sera sere serf seta sets sewn sews sext sexy shah sham shed shew shim shin ship shiv shmo shoe shoo shop shot show shun shut shwa sick side sift sigh sign sikh siku silk sill silo silt sine sing sink sins sips sire sirs site sits sitz size skep skew skid skim skin skip skis skit slab slam slap slat slaw slay sled slew slid slim slip slit slob sloe slog slop slot slow slug slum slur smit smog smug smut snag snap snip snit snob snog snot snow snub snug soak soap soar sobs sock soda sods sofa soft soil sold sole soli solo sols some soms sone song sons soon soot sops sore sort sots soul soup sour sown sows soya soys spam span spar spas spat spay sped spin spit spot spry spud spun spur stab stag star stat stay stem step stew stir stop stow stub stud stun stye styx subs such suck suds sued suer sues suet suit sulk sumo sump sums sung sunk suns suqs sure surf swab swag swam swan swap swat sway swig swim swiz swop swum sync tabs tabu tack taco tact tags tail taka take tala talc tale talk tall tame tamp tams tank tans tape taps tare tarn taro tarp tars tart task taus taut taxa taxi teak teal team tear teas tech teed teem teen tees tell tend tens tent term tern terp test teth text than that thaw thee them then they thin this thou thru thud thug thus tick tics tide tidy tied tier ties tiff tike tile till tilt time tine ting tins tint tiny tipi tips tire tizz toad toed toes toff tofu toga toil toke told toll tomb tome toms tone tong tons took tool toot tops tore torn toro tort toss tote tots tour tout town tows toys tram trap tray tree trek trim trio trip trod tron trot troy true tsar tuba tube tubs tuck tufa tuff tuft tugs tums tuna tune turf turn tusk tutu twig twin twit twos tyke type typo tyro tzar ughs ugly ukes ulna umbo umps undo unit unix unto upon urea urge uric urns used user uses uvea vain vale vamp vane vang vans vape vara vary vase vast vats vatu veal vear veer vees veil vein vela vend vent verb very vest veto vets vial vibe vice vied vies view vile vine viol visa vise vita voes void vole volt vote vows vugs wack wade wadi wads waft wage wags waif wail wait wake wale walk wall waly wand wane want ward ware warm warn warp wars wart wary wash wasp watt wauk waul wave wavy wawl waxy ways weak weal wean wear webs weds weed week ween weep weir weld well welt wend went wept were west wets wham what when whet whew whey whim whip whir whiz whoa whom whop whup wick wide wife wifi wigs wild wile will wilt wily wimp wind wine wing wink wins wipe wire wiry wise wish wisp wist with wits wive woad woes woke woks wolf womb wons wont wood woof wool woos word wore work worm worn wort wove wows wrap wren writ wyes xray xyst yack yaff yagi yaks yald yams yang yank yaps yard yare yarn yaud yaup yawl yawn yawp yaws yeah yean year yeas yegg yeld yelk yell yelm yelp yens yerk yesk yeti yett yeuk yews yill yins yipe yips yird yirr ynal yodh yods yoga yogh yogi yoke yolk yond yoni yore your yowe yowl yows yoyo yuan yuck yuga yuks yule yurt yutz ywis zags zany zaps zarf zati zeal zebu zeds zees zein zens zeps zerk zero zest zeta zhos zigs zinc zine zing zips ziti zits zizz zoea zoic zone zonk zoom zoon zoos zori zulu zyme"
four_letter = four_letter.split(" ")

five_letter = "aahed aargh abaci aback abamp abase abash abate abbey abbot abear abets abhor abide abler ablur abmho abode abohm abore aborn abort about above abray absit abuse abuts abuzz abysm abyss acate accoy acene acers ached acher aches achoo acids acidy acing acned acnes acorn acres acrid acted acter actin actor acute acyls adage adapt added adder addle adept adfix adhoc adieu adios adlib adman admin admit admix adobe adopt adore adorn aduki adult adzes aeons aerie affix afire aflow afoot afoul afros after again agape agars agast agate agaty agave agent agile aging aglet aglow agony agora agree agrin agues ahead aided aider aides ailed aimed aimer aioli aired airer aisle aitch akene alarm album alder aldol aleph alert algae algal alias alibi alien align alike alive alkyd alkyl allay alley allot allow alloy allyl aloes aloft aloha alone along aloof aloud alpha altar alter altos alula alums amass amaze amber ambit amble ambos ambry ameba ameer amend amens ament amide amigo amine amino amiss amity among amour ample amply amuck amuse amyls angel anger angle angry angst anime anion anise ankle annal annex annoy annul anode anons antic antra antsy anvil aorta apart aphid aping apish apnea appel apple apply april apron apter aptly aquas arbor arced ardor areal areas arena argon argue arhat arias arils arise armed armer armet armor aroma arose array arrow arson artsy aryls aryne ascot ascus ashed ashen asher ashes aside asked askew aspen asper aspic assay asses asset aster astir async atlas atoke atoll atoms atone atony atopy atria attic audio audit auger aught augur aulos aunts aunty aural auras auric autos auxin avail avens avers avert avian avium avoid avows await awake award aware awash aways awful awing awned awoke awols axels axial axils axing axiom axion axite axled axles axman axmen axoid axons azene azide azine azlon azoic azole azote azoxy azuki azure azury azygy azyme azyms baaed babes backs bacon badge badly bagel baggy bahts bails bairn baits baked baker bakes balds baled baler bales balks balky balls balms balmy balsa banal bands bandy baned banes bangs banjo banks barbs bards bared barer bares barfs barge barks barms barmy barns barny baron barre basal based baser bases basic basil basin basis basks baste batch bated bates bathe baths batik baton batty bauds baulk bawds bawdy bawls bayed bayou beach beads beady beaks beams beans beard bears beast beats beaus bebop becks bedew bedim bedub bedye beech beefs beefy beeps beers beery beets beety befit began beget begin begot begun beige beigy being belay belch belie belle bells belly below belts bemud bench bends bendy benes beret berks berms berry berth beryl beset besot bests betas betel bevel bewig bible biddy bided bides bidet bifid bigly bigot bijou biker bikes bilge bilgy bilks bills binds binge bingo biogs biome biota biped bipod birch birds birrs birth bison biter bites bitsy bitts bitty blabs black blade blahs blame bland blank blare blast blats blaze bleak blear bleat blebs bleed bleep blend bless blest blimp blind bling blink blips bliss blitz bloat blobs block blocs blogs bloke blond blood bloom blots blown blows blowy blued bluer blues bluet bluey bluff blunt blurb blurs blurt blush board boars boast boats bobby bocal boded bodes bodys boffo bogey boggy bogie bogus boils bolds bolix bolls bolts bolus bombs bonds boned bones boney bongo bongs bonks bonny bonus booby booed books booms boomy boons boors boose boost booth boots booze boozy borax bored borer bores boric borne boron bosom boson bossy botch bough bound bouse bousy bouts bovid bowed bowel bower bowls boxed boxen boxer boxes boysy brace bract brads brady brags braid brail brain brake brand brank brash brass brats brave bravo brawl brawn brays braze bread break bream breed breve brews briar bribe brick bride brief brier brill brims brine bring brink brins briny brisk brith broad broil broke bronc bronx brood brook broom broth brown brows bruit brunt brush brute bruxs bucks buddy budge buffs buffy buggy bugle buhls buhrs build built bulbs bulge bulgy bulks bulky bulla bulls bully bumps bumpy bunch bungs bunks bunny bunts buoys burgh burka burls burly burns burnt burps burqa burro burrs bursa burst bused buses bushy busks busts butte butts butty butyl buxom buyer bylaw bytes byway cabal cabby cabin cable cacao cache cacti caddy cadet cadge cadre caeca cafes caged cages cagey cairn caked cakes cakey calfs calif calla calli calls calms calve calyx camel cameo camps canal candy caned caner canes canid canna canny canoe canon canst canto cants caped caper capes capon capri carat carbs cards cared carer cares caret cargo carny carob carol carpi carps carry carts carve cased cases casks caste casts catch cater catty caulk cause caval caved caver caves cavil cawed cease cebid cecal cecum cedar ceded ceder cedes cedis cello cells cents cered ceres certs chafe chaff chain chair chalk champ chant chaos chaps chapt chara chard charm chars chart chary chase chasm chats cheap cheat check cheek cheep cheer chefs chert chess chest chevy chews chewy chick chide chief child chili chill chime chimp china chins chips chirp chive chivs chock choir choke chomp chops chord chore chose choux chows chubs chuck chuff chugs chump chums chunk churl churn chute chyle chyme cider cigar cilia cinch circa cirri cisco cited citer cites civet civic civil clack clade clags claim clamp clams clang clank clans claps clash clasp class clast clave claws clays clean clear cleat clefs cleft clerk click cliff climb clime cline cling clink clips cloak clock clods clogs clomp clone clonk clops close cloth clots cloud clout clove clown cloys clubs cluck clued clues clump clung clunk cluse cnida coach coact coaid coaks coals coaly coarb coast coati coats cobra cocci cocks cocky cocoa cocos codec coded coder codes codex codon coeds cohos coifs coils coins coked cokes colas colds colic colon color colts comae comas combo combs comer comes comet comfy comic comma conch condo coned cones conic conks cooba cooed cooks cools coops coopt coots coown copay coped coper copes copra copse coral cords cored corer cores corgi corks corms corns cornu corny corps costa costs couch cough could count coupe coups court coved coven cover coves covet cower cowls coyer coyly cozey crabs crack craft crags crake cramp crams crane crank crape craps crash crass crate crave crawl craws crays craze crazy creak cream credo creed creek creep crepe crept cress crest crews cribs crick cried crier cries crime crimp crisp croak crock croft crone crony crook croon crops cross croup crowd crown crows crude cruds cruel cruet cruft crumb crura crush crust crwth crypt cubby cubed cuber cubes cubic cubit cuddy cuffs cuing culls culms cults cumin cumol cupid curbs curby curds curdy cured curer cures curia curio curls curly curry curse curst curve curvy cushy cusps cuter cutey cutie cutin cutis cutty cutup cwtch cyans cyber cycle cymas cymes cymol cynic cysts czars daddy dados daffy daily dairy daisy dalet dally damed dames damns damps dance dandy dared darer dares darks darns darts dated dater dates datum daube daubs daunt davit dawns dazed dazes deads deair deals dealt deans dears deary deash death deave debar debit debts debud debug debus debut decaf decal decap decay decks decor decoy decry deeds deems deeps deers deets defat defer defog degas degum degut deice deify deign deils deink deism deist deity delay deled deles delfs delft dells delta delve demap demes demit demob demon demos demur denar denes denim dense dents denty deoxy depot depth deray derby derma derms derry desex desks deter detox deuce devas devel devil devon dewan dewax dewey dhole dhoti dhows dials diary diced dicer dices dicey dicot diddy didst diene diets diety digit diked dikes dills dilly dimer dimes dimly dinar dined diner dines dingo dings dingy dinky dints diode dione dipod dippy direr dirge dirts dirty disco discs disks ditch ditsy ditto ditty ditzy divan divas dived diver dives divot divvy diyne dizzy dobra docks dodge dodgy dodos doers doest doges doggy dogma doily doing dojos doled doles dolls dolly dolts domed domes dongs donor donut dooms doors doozy doped doper dopes dopey dorks dorky dorms dorrs dosed doses doted doter dotes dotty doubt dough douse doves dovey dowds dowdy dowed dowel dower dowly downs downy dowry dowse doxed doxes doyen dozed dozen dozer dozes drabs draft drags drain drake drama drams drank drape drawl drawn draws drays dread dream drear dregs dress dreys dribs dried drier dries drift drill drink drips drive droid droit droll drone drool droop drops dross drove drown drubs drugs druid drums drunk drupe drury druse drusy druzy dryad dryer dryly duals ducat ducks ducky ducts dudes duels duets dukes dulce dulls dully dumbs dummy dumps dumpy dunce dunes dungs dungy dunks duped duper dupes dural dusky dusts dusty dutar duvet dwarf dweeb dwell dwelt dyads dyers dying dyked dynes eager eagle eared earls early earns earth eased easel easer eases eaten eater eaves ebbed ebola ebony ebook echos ecrus edema edged edger edges edict edify edits educe educt eeler eerie eggar egged egger egret eider eight eject eking eland elate elbow elder elect elegy elfin elide elite ellis eloge elogy eloin elope elude elute elven elves email embed ember emcee emend emery emirs emits emmys emoji emote empty enact enbus ended endow enema enemy enjoy enols enrol ensue enter entry envoy enyne eosin epics epoch epoxy equal equid equip erase erect ergon erode erose erred error eruct erupt ervil esker essay ester ether ethic ethos ethyl euros eusol evade evens event evert every evict evils evite evoke ewers exact exalt exams excel execs exert exile exist exits exons expat expel expos extol extra exude exult eying fable faced faces facet facie facts faddy faded fades fails fains faint fairs fairy faith faked faker fakes falls false famed fancy fangs farad farce fared fares farms fasts fatal fated fates fatly fatty fatwa faugh fault fauna fauns favor fawns faxed faxes fazed fazes fears feast feats feaze fecal feces fedup feeds feels feese feeze feign feint fella fells felon felts felty femme femur fence fends feral ferns ferny ferry fetal fetas fetch fetid fetor fetus feuds fever fewer fezes fezzy fiber fibre fibry fiche fiefs field fiend fiery fifth fifty fight filch filed filer files filet fills filly films filmy filth final finch finds fined finer fines finis finny fired firer fires firms first fishy fists fitly fiver fives fixed fixer fixes fixup fizzy fjord flabs flack flaff flags flail flair flake flaky flame flank flans flaps flare flash flask flats flaws flaxs flaxy flays fleas fleck flees fleet flesh flick flier flies fling flint flips flirt flits float flock floes flogs flood floor flops flora flory floss flour flout flown flows flubs flues fluey fluff fluid fluke fluky flume flump flung flunk flush flute flyby flyer foals foams foamy focal focus fogas fogey foggy foils foist folds foley folia folic folio folks folly fonds fonts foods fools footy foppy foray forbs force forge forgo forks forms forte forth forts forty forum fossa fouls found fours fovea foxed foxer foxes foyer frail frame franc frank fraud frays freak freed freer frees freon fresh frets friar fried frier fries frill frisk frizz frock frogs frond front frore frorn frory frosh frost froth frown froze fruit frump fryer fudge fudgy fuels fuffs fuffy fugue fully fumed fumer fumes funds fungi funks funky funny furan furls furor furry fused fusee fusel fuser fuses fussy futon fuzed fuzes fuzzy gabby gable gaffe gaffs gaged gager gages gaily gains gaits galas gales galls gamed gamer games gamey gamma gamut ganef ganev gangs ganof gaols gaped gapes gappy garbs gases gasps gaspy gassy gated gates gator gauds gaudy gauge gaunt gauss gauze gauzy gavel gawks gawky gawps gayer gayly gazed gazer gazes gears gecko geeks geeky geese genes genet genie genoa genre gents genus geode geoid germs germy getup ghost ghoul giant giddy gifts gigas gijak gilds gills gimel gimps gipsy girds girly girns girth gismo given giver gives gizmo glade glamp gland glare glass glaze gleam glean gleek glees gleet glial glide glint glitz gloam gloat globe globs gloom glory gloss glove glows gloze glued gluer glues gluey glugs gluon gluts glyph gnarl gnarr gnars gnash gnats gnawn gnaws gnome goads goals goats gobby godly goers gofer going gojis golds golfs golgi golly gonad goner gongs gonif gonna gonof goods goody gooey goofs goofy goons goops goopy goose goosy gored gores gorge goths gotta gouda gouge gound gourd gouts gouty gowns grabs grace grade grads graff graft grail grain grams grand grant grape graph grasp grass grate grave gravy grays graze great greed greek green greet greys grids grief grill grime grimy grind grins griot gripe grips grist grits groan groin groom grope gross group grout grove growl grown grows grubs gruel gruff grump grunt guano guard guava gucks gucky guess guest guide guild guile guilt guise gulag gulch gulfs gulls gully gulps gumbo gummy gunks gunky gunny guppy gurns gurus gushy gussy gusto gusts gusty gutsy gutty guyed gynes gypsy gyres gyros gyrus habit hacks hades hadst haiku hails hairs hairy halls halos halts halux halva halve hands handy hangs happy hards hardy hared harem hares harks harms harps harpy harsh hasps haste hasty hatch hated hater hates hauls haunt haven haves havoc hawed hawks hawse hayed hayer hazed hazel hazer hazes heads heady heald heals heaps heard hears heart heath heats heave heavy hedge heeds heels hefts hefty heirs heist helix hello hells helms helps hemin hence henna henry herbs herds heres heron heros hertz hetch hewed hewer hexed hexes hicks hider hides highs hijab hiked hiker hikes hilar hills hilly hilts hilum hinds hinge hinny hints hippo hippy hired hirer hires hissy hitch hived hiver hives hoagy hoard hoary hobby hobos hocks hoist holds holed holes holey holly homed homer homes honed honer hones honey honks honor hoods hooey hoofs hooks hooky hoops hoots hoove hoped hopes horde horns horny horos horse hosed hoser hoses hosta hosts hotel hotly hound hours house hovel hoven hover howdy howls howto hubby huffs huffy huger huggy hulas hulks hulky hulls human humic humid humor humps humpy humus hunch hunks hunky hunts hurls hurry hurts husks husky hutch hydra hydro hyena hylid hymen hymns hyoid hyped hyper hypes hypha hypos hyrax iambs icers icier icily icing icons ideal ideas idiom idiot idled idler idles idols idyll igloo ileac ileal ileum ileus iliac ilium image imago imams imbed imide imped impel imply inane inbox incar incur index inept inert infer infix ingot inked inlaw inlay inlet inmix inner inode input inset inter inula inure iodic ionic iotas ipads irate irids iring irked irons irony isles islet issue itchy items ivied ivies ivory jacks jaded jades jails jalis jambs jammy jaunt jawed jazzy jeans jeeps jeers jehad jelis jello jells jelly jembe jerks jerky jests jetty jewel jibed jiber jibes jiffy jihad jilts jimmy jingo jinks jived jiver jives jivey jocks johns joins joint joist joked joker jokes jolly jolts joule joust jowls jowly joyed judge jugum juice juicy juked jukes julep julys jumbo jumps jumpy junes junks junta juror jutes juxta kabab kabal kabob kales kaons kappa karat karma karst katal katas kavas kayak kazoo kebab keeks keels keens keeps kegel kelps kelpy kerns ketol kexin keyed khaki kicks kicky kiddo kills kilns kilos kilts kinas kinds kings kinks kinky kiosk kissy kited kites kitty kiwis klutz knack knarl knars knaur knave knead kneed kneel knees knell knelt knick knife knish knits knobs knock knoll knots known knows knurl knurs koala kooks kooky krill krona krone kroon kudos kudus kudzu kunas kvell kyaks kyats label labor laced lacer laces lacey lacks laded laden lades ladle lager lahar lairs laker lakes lambs lamed lamer lames lamps lance lands lanes lanky lapel lapse larch lards lardy large largo laris larks larva lased laser lasik lasso lasts latch later latex lathe laths latke latte lauds laugh lavas laved laves lawns laxer laxes laxly layed layer layup lazed lazes lazys leach leads leafs leafy leaks leaky leans leant leaps leapt learn leary lease leash least leave ledes ledge ledgy leech leeks leers leery lefts lefty legal leggy legit lemma lemon lemur lends lense leone leper letup levee level lever liars libel liber libre licit licks liens lifer lifes lifts light liked liken liker likes lilac lilts limbo limbs limed limes limit limns limos limps lined linen liner lines lingo links linty lions lipid lippy liras lirks lisps lists litas liter lithe litre lived liven liver lives livid llama loads loafs loams loamy loans loath lobar lobby lobed lobes local lochs locks locos locum locus lodes lodge loess lofts lofty logic login logon logos loins loner longa longe longs looks looms loons loony loops loopy loose loots loped lopes lords lores loris lorry loser loses lossy lotis lotto lotus louse lousy louts loved lover loves lovey lower lowly loxes loyal lubed lubes lucid lucks lucky ludes luffa luffs luges lulls lumen lumps lumpy lunar lunch lunge lungs lupin lupus lurch lured lurer lures lurid lurks lusts lusty lutes luxes lyase lycra lying lymph lyres lyric lysis lytic macau macaw maced maces macho machs macro madam madly mafia mafic magic magma maids mails maims mains maize major maker makes males malls malts malty mamas mamba mambo manat maned manes manga mange mango mangy mania manic manly manna manor maple march mares marka marks marls marry marsh marts masks mason masts match mated mater mates matey maths matte matts mauls mauve maven mavin maxim maybe mayor mazed mazer mazes mbila mbira meals mealy means meant meany meats meaty medal media medic meets melds melee melon melts memes memos mends menus meows mercy merge merit merry mesas meshs mesic meson messy metal meted meter metes metre metro mewed miasm micas micro midas midst might miler miles milks milky mills mimed mimeo mimes mimic mince minds mined miner mines minim minis minks minor mints minty minus mired mires mirth misdo miser mises missy mists misty miter mites mitre mitts mixed mixer mixes mixup moans moats mocha mocks modal model modem modes modus mogul mohar mohel moist molar molds moldy moles molly molts momma mommy monad money monks month mooch moods moody mooed moons moors moory moose moots moped moper mopes mopey moral moray morel mores moron morph morse morts mosey mossy motel moths mothy motif motor motte motto mould moult mound mount mourn mouse mousy mouth moved mover moves movie mowed mower mucin mucks mucky mucus muddy muffs muggy mujik mulch mules mulls mummy mumps munch munge muons mural murks murky mused muser muses mushy music musks musky mussy musts musty muted muter mutes mutts muzzy mycin mynah mynas myoma myrrh myths nabal nabob nacho nadir naiad nails naira naive naked nakfa named namer names nands nanny napes nares nasal nasty natal natty nauts naval navel naves nazis neaps nears necks needs needy negro neigh neons neper nerds nerdy nerve nervy nests neume never nevus newel newer newly newsy newts nexus nggam ngwee nicer niche nicht nicks niece nifty night nines ninja ninny ninth nippy nitro nitty nixed nixes noble nobly nocks nodal nodes noels nohow noise noisy nomad nonce nooks noons noose norms norse north nosed noses nosey notch noted notes nouns novae novas novel noway nubby nuder nudes nudge nudie nuked nukes nulls numbs nurse nutsy nutty nyele nylon nymph oaken oared oases oasis oaths obese obeys oboes occur ocean ocher ochre ocrea octal octet octos oculi odder oddly odist odors odour offer often ogham ogled ogler ogles ogres ohmic oiled oiler oinks okays okras olden older oldie oleas oleic olive omega omens omits onion onmap onset ontic oohed ooids ootid oozed oozer oozes oozey opals opens opera opine opium opted optic orals orate orbit order organ ortet ortho oscar other otter ought ouija ounce ousts outdo outed outer outgo ouzos ovale ovals ovary ovate ovens overo overs overt ovine ovoid ovula ovule owers owing owled owler owlet owned owner oxane oxbow oxboy oxeas oxens oxeye oxide oxlip oxter ozone paced pacer paces packs pacts paddy padre paean pagan paged pager pages pails pains paint pairs palea paled paler pales palls palms palmy palps palsy panda paned panel panes pangs panic pansy pants panty papal papas paper parch pared parer pares parge parka parks parry parse parti parts party parvo pasta paste pasts pasty patch pater paths patio patty pause paved paves pawed pawns payed payee payer peace peach peaks peals pearl pears peats peaty pecan pecks pedal peeks peels peeps peers peeve pelfs pelts penal pence pends penis penny pents peons peony pepos peppy perch peril perks perky perms perts pesky pesos pesto pests pesty petal peter petit petty pewee pewit phage phase pheon phish phlox phone phony photo phubs phyla phyma piano picas picks picky piece piers pieta piety piggy pigmy piked pikes pilaf piled piler piles pills pilot pimps pinch pined pines pingo pings pinks pinky pinna pinto pints pinup pions pious piped piper pipes pipet pipit pique pissy pitas pitch piths pithy piton pivot pixel pizza place plaid plain plait plane plank plans plant plash plate platy playa plays plaza plead pleas pleat plebs plied plier plies plink plods ploid plonk plook plops plots plouk plows ploys pluck pluff plugs plumb plume plump plums plumy plunk plush poach pocks poems poesy poets point poise poked poker pokes polar poled poles polio polka polls polyp ponds pooch poohs pools poops popes poppa poppy popup porch pored porer pores porks porky porns porny porte ports posed poser poses posit posse posts potty pouch poufs poult pound pours pouts pouty power poxed poxes prams prank prate prawn prays preen preon preop preps press preys price prick pricy pride pried prier pries prime primo primp print prion prior prism privy prize probe prods proms prone prong proof props prose proud prove prowl prows proxy prude prune pryer psalm psion psych pubic puces pucks pudgy puffs puffy pugil puked puker pukes pulas pulls pulps pulpy pulse pumas pumps punch punks punny punts pupae pupal pupil puppy pured puree purer pures purge purrs purse pushy pussy putti putto putts putty pygmy pylon pzazz qabal qadis qaids qanat qophs quack quads quaff quail quake quaky qualm quant quark quart quash quays qubit queen queer quell query quest queue quich quick quids quiet quiff quill quilt quins quint quips quire quirk quite quits qumix quota quote rabab rabid raced racer races racks radar radii radio radix radon rafts raged rager rages raids rails rains rainy raise rajah raked raker rakes rally ramen ramet rammy ramps ramus ranch rands randy range rangy ranid ranks rants raped raper rapes rapid rarer rares rashy rasps raspy rated rater rates ratio ratty raved ravel raven raver raves rawer raxed raxes rayed rayon razed razee razer razes razor reach react readd reads ready reaks realm reals reams reaps rearm rears reask reast reave rebab rebag reban rebar rebel rebid rebin rebit rebop rebox rebus rebut rebuy recap recon recur recut redid redip redon redox redry redub redux redye reeds reedy reefs reefy reeks reeky reels reest reeve refax refed refer refit refix refry regal regas regel rehab rehem rehid reice reify reign reink reins rejet rejig rejog rekey relax relay relic relit relog remap remex remit remix remow renal rends renet renew renin rents reoil repad repay repeg repel repen repin reply repop repot reran rerun resat resaw resay reset resew resin resit resod resow rests resum retag retap retax retch retee retie retro retry reuse revel revue rewax rewed rewet rewon rezip rheme rheum rhino rhomb rhyme rials riced ricer rices ricin ricks rider rides ridge ridgy riels rifer riffs rifle rifts right rigid rigor riled riles rille rills rilly rimed rimes rinds rings rinks rinse riots riped ripen riper ripes risen riser rises risks risky rited rites ritzy rival rived riven river rives rivet riyal roach roads roams roans roars roary roast robab robed robes robin robot rocks rocky rodeo rodes roger rogue roils roily roist roles rolls roman romps roods roofs rooks rooms roomy roost roots roped roper ropes ropey roses rosey rosin roton rotor roues rouge rough round rouse route routs roved rover roves rowdy rowed rower royal rubab ruble ruddy ruder ruffs rugby ruing ruins ruled ruler rules rumba rummy rumor rumps runes rungs runic runin runny runts runty rupee rural ruses rushy rusts rusty rutes rutty saber sable sabre sacks sacra sadhe sadly safer safes sagas sager sages saggy sails saint saith sakes salad sales salon salsa salts salty salve samba sands sandy saner sanes sansu sanza sappy sards sarin saris sassy satan satay sated sates satin satyr sauce saucy sauna saute saved saver saves savor savvy sawed sawer saxes sayee sayer scabs scald scale scalp scaly scamp scams scans scant scape scare scarf scarp scars scary scats scene scent scion scoff scold scone scoop scoot scope score scorn scots scour scout scowl scrag scram scrap scree screw scrim scrip scrub scrum scuba scuds scuff sculk scums scurf scute scuzz seals seams seamy sears seats sebum secco sects sedan sedge sedgy sedum seeds seedy seeks seems seeps seepy seers segue seine seize sella sells semen semes semis sends senna senor sense sepal sepia septa serac seral sered serer seres serfs serif serum serve setae setal setup seven sever sewed sewer sexed sexes sexts shack shade shady shaft shags shahs shake shaky shale shall shalt shaly shame shams shank shape shard share shark sharp shave shawl sheaf shear sheds sheen sheep sheer sheet sheik shelf shell shewn shews shied shier shies shift shill shims shine shins shiny ships shire shirk shirt shish shivs shoal shock shoed shoer shoes shone shook shoot shops shore shorn short shots shout shove shown shows showy shred shrew shrub shrug shtik shuck shuns shunt shush shuts shwas shyer shyly sibyl sicko sicks sided sides sidle siege sieve sifts sighs sight sigma signs sikhs sikus silks silky sills silly silos silts silty since sines sinew singe sings sinks sinus sippy sired siren sires sitar sited sites sitin situp sixer sixes sixmo sixth sixty sizar sized sizer sizes skate skeet skelp skeps skews skids skied skier skies skiey skiff skill skimp skims skink skins skips skirl skirt skits skulk skull skunk skwal slabs slack slags slain slake slams slang slant slaps slash slate slats slaty slave slaws slays sleds sleek sleep sleet slept slews slice slick slide slier slily slime slims slimy sling slink slips slits slobs slock sloes slogs sloop slope slops slosh sloth slots slows slugs slump slums slung slurp slurs slush slyer slyly smack small smarm smart smash smear smell smelt smile smily smirk smite smith smock smogs smoke smoky smote smugs smuts snack snafu snags snail snake snaky snaps snare snarf snark snarl sneak sneer snick snide sniff snipe snips snits snobs snoek snogs snood snoop snoot snore snort snots snout snows snowy snubs snuck snuff snugs soaks soaky soaps soapy soars sober sobor socks sodas soddy sodic sofas softa softy soggy soils solar soled soles solid solos solve sonar sonde sones songs sonic sonny sooth soots sooty sopor soppy sorer sores sorgo sorry sorts souls sound soups soupy sours south sowed sower soyas space spade spall spams spank spans spare spark spars spasm spate spats spawn spays speak spear speck specs speed spell spelt spend spent sperm spews sphex spica spice spicy spied spiel spier spies spiff spike spiky spill spilt spine spins spiny spire spiro spiry spite spits spitz splat splay split spoil spoke spoof spook spool spoon spoor spore sport spots spout sprag sprat spray spree sprig sprit sprue spuds spume spumy spurn spurs spurt squab squad squat squib squid stabs stack staff stage stags stagy staid stain stair stake stale stalk stall stamp stand staph stare stark stars start stash state stats stave stays stead steak steal steam steed steel steep steer stein stele stems steno stent steps stern stews stick sties stiff still stilt stimy sting stink stint stirs stive stivy stock stogy stoic stoke stole stoma stomp stomy stone stony stood stool stoop stops stopt store stork storm story stoup stout stove stows strap straw stray strep strew strip strop strow strum strut stubs stuck studs study stuff stump stung stunk stuns stunt stupa stupe styed styes style styli stymy suave subah sucks sucky sudsy suede suers suets suety sugar suing suite suits sulfa sulks sulky sully sumac sumos sumps sunny sunup super supra surer surfs surge surgy surly sushi swabs swags swami swamp swamy swang swank swans swaps sward swarm swash swath swats sways swear sweat sweep sweet swell swept swift swigs swill swims swine swing swipe swirl swish swizz swoon swoop swops swopt sword swore sworn swung sylph sylva synch synod syrup tabby tabid table taboo tacit tacks tacky tacos taffy taggy taiga tails taint takas taken taker takes talas talcs tales talks talls tally talon talus tamed tamer tames tamps tango tangy tanks tansy tapas taped taper tapes tapir tardy tares tarns taros tarot tarps tarry tarsi tarts taser tasks taste tasty tatar tatoo taunt taupe tawny taxed taxer taxes taxis taxon tazza teach teaks teals teams tears teary tease teats teaux teaze techs techy teddy teems teens teeny teeth telco telex tells telly tempo temps tempt tends tenet tenge tenon tenor tense tenth tents tenty tepal tepee tepid terms terns terps terry terse tesla tests testy tetra texel texts thank thats thaws theft their theme thens there therm these thesp theta thick thief thigh thine thing think thins third thong thorn those thous three threw throb throe throw thrum thuds thugs thumb thump thunk thyme thymy tiara tibia ticks tidal tides tiers tiffs tiger tight tikes tilde tiled tiler tiles tills tilts tilty timed timer times timid tinea tined tines tinge tings tinny tints tinty tipis tiple tippy tipsy tired tires titan titer tithe title titre tizzy toads toady toast today toddy toffs tofus togas toile toils toked token toker tokes tolls tombs tomes tonal tondo toned toner tones tongs tonic tonne tools tooth toots topaz topic toque torah torch torso torte torts torus total toted totem toter totes touch tough tours touts towed towel tower towns toxic toxin toyed trace track tract trade trail train trait tramp trams traps trash trawl trays tread treat treed trees treks trend trent tress triad trial tribe trick tried trier tries trike trill trims triod trios tripe trips trite troll trone trons troop trope trots trout trove truce truck truer trues truly trump trunk truss trust truth tryst tsadi tsars tubal tubas tubax tubby tubed tuber tubes tucks tufas tuffs tufts tufty tulip tummy tumor tunas tuned tuner tunes tunic tuple turbo turfs turfy turks turns tusks tutor tutus tuxes twang tweak tweed tweet twerp twice twigs twill twine twins twirl twirp twist twits twixt tying tykes typed typer types typos tyres tzars udder ulcer ulmic ulnae ulnar ulnas ultra umbel umber umbos umped unarm unary unbag unban unbar unbid unbox uncap uncle uncup uncut undam under undid undim undue unfed unfit unfix unhip unify union unite units unity unjam unled unlit unlog unman unmap unmet unpeg unpen unpin unrig unsay unset unsex unshy untag untie until unwed unzip updip upend upped upper upset urase urate urban ureas urged urger urges urine usage users usher using usual usurp usury utile utter uvula vagal vague vagus vales valet valga valid valor value valve vamps vaned vanes vaped vaper vapes vapid vapor varas varix varna varum varus vases vatus vault vaunt veals vears veers vegan veils veily veins veiny velum venal vends venin venom vents venue venus verbs verge verse vests vetch vexed vexer vexes vexil vials vibes vicar vices video views vigil vigor viler villa villi vinca vined vines vinyl viola viols viper viral virus visas vised vises visit visor vista vitae vital vivid vixen vocal vodka vogue voice voids voila voles volts vomit voted voter votes vouch vowed vowel vower voxel vraic vroom vuggy vulva vying wacko wacks wacky waddy waded wader wades wadis wafer wafts waged wager wages wagon waifs wails waist waits waive waked waken waker wakes waled wales walks walls wally waltz wands waned wanes wanna wants wards wared wares warms warns warps warts warty washy wasps waspy waste watch water watts wauks waulk wauls waved waver waves wavey wawls waxed waxen waxer waxes wazza weals weans wears weary weave webby weber wedge wedgy weeds weedy weeks weens weeny weeps weepy weigh weird weirs welch welds wells welsh welts wench wends wetly whack whale whams wharf whats wheal wheat wheel whelk whelm whelp where whets which whiff while whims whine whiny whips whirl whirr whirs whisk whisp white whits whizz whole whoop whops whorl whose whoso whups wicks widen wider wides widow width wield wight wilds wiled wiles wills wilts wimps wimpy wince winch winds windy wined wines winge wings winks wiped wiper wipes wired wirer wires wised wiser wises wishy wisps wispy witan witch witty wived wives wizen woads woken wolfs woman wombs women wonky wonts woods woody wooed wooer woofs wools wooly woozy words wordy works world worms wormy worry worse worst worth worts would wound woven wowed wrack wraps wrapt wrath wreak wreck wrens wrest wrier wring wrist write writs wrong wrote wrung wryer wryly wurst wussy xebec xenia xenic xenon xeric xerox xerus xrays xylan xylem xylic xylol xylyl xysti xysts yacht yacks yaffs yager yagis yahoo yaird yamen yamun yangs yanks yapok yapon yards yarer yarns yauds yauld yaups yawed yawls yawns yawps yeahs yealm yeans yearn years yeast yeggs yelks yells yelms yelps yerba yeses yesks yetis yeuks yeuky yexed yexes yield yills yince yipes yirds yirrs yirth ynals ynone yodel yodhs yodle yogas yogee yoghs yogic yogin yogis yoked yokel yokes yolks yolky yomim yonis yores young yourn yours youse youth yowed yowes yowie yowls yoyos yuans yucca yucks yucky yugas yukky yulan yules yummy yupon yurta yurts zamia zanza zappy zarfs zatis zaxes zayin zeals zebec zebra zebub zebus zeins zerks zeros zests zesty zetas zibet zilch zincs zincy zines zings zingy zinky zippy ziram zitis zloty zoaea zoeae zoeal zoeas zombi zonal zonda zoned zoner zones zonks zooea zooid zooks zooms zoons zooty zoril zorse zowie zulus zuzim zymes zymic zymin"
five_letter = five_letter.split(" ")

six_letter = "aahing abacus abamps abased abaser abases abasia abasic abated abater abates abatic abator abbess abbeys abbots abduce abduct abears abhors abided abider abides abject abjure ablate ablaze ablest abloom ablude ablush ablute abmhos aboard aboded abodes abohms abonne aboral aborne aborts abound abouts abrade abraid abrase abrash abrays abroad abrupt abseil absent absits absorb absurd abulia abulic abused abuser abuses abvolt abwatt abysms acacia acater acates acatry accede accent accept access accite accloy accord accost accoys accrue accuse acenes acetic acetyl achene achier aching acidic acidly acinic acinus acnode acomia acopic acorns acquit across actant acting actins action active actors actual acuate acuity aculei acumen acuter acutes adages adapts addend adders addict adding addled addler addles adduce adduct adepts adhere adhorn adieus adjigo adjoin adjure adjust adjute adlibs admins admire admits admixt adnexa adobes adonic adopts adored adorer adores adorns adrift adroit adsorb adukis adults advent adverb advert advice advise adware adzuki aedile aerate aerial aerier aether affair affect affine affirm affixt afford affray afghan afield aflame afloat afraid afresh afters agapes agaran agaric agates ageing agency agenda agents ageold aghast agings agleam aglets agogic agouti agreed agrees aiders aidful aiding aiglet aigret ailing aimers aiming aiolis airbag airbed airbus airdry airgap airgun airier airily airing airish airman airmen airway aisled aisles ajoint akenes alanyl alarms alarum alaska albedo albeit albino albite albums alcove alders aldols aldose alecup alephs alerts alibis alidad aliens alight aligns alikes alkali alkane alkene alkoxy alkyds alkyne allays allege allele alleve alleys allied allier allies allium allots allows alloys allude allure almond almost alobar alpaca alpeen alphas alpine altars alters alulas alumel alumna alumni always amazed amazes amazon ambers ambits ambled ambler ambles ambush amebae amebas amebic amelia amends aments amerce amides amidst amigos amines ammine amnion amoeba amoral amorph amount amours amoxil ampere ampler ampule amrita amulet amused amuses anagen anally analog ananym anarch anchor anding anemia anemic angels angers angina angled angler angles angsts angsty animal animus anions anises anitis ankled ankles anklet annals anneal annoys annual annuli annuls anodal anodes anodic anoint anomer anonym anotia anoxia anoxic answer anthem anther antics anting antler antral antrum anuses anvils anyhow anyone anyway aortal aortas aortic apache apathy apeman apemen apexed apexes aphids apiary apical apices apiece aplite aplomb apogee apolar apolog apozem appall appeal appear appels append apples applet appose aprils aprons aptest arable arbors arbour arcade arcana arcane arched archer arches archly archon arcing arctan arctic ardent ardors ardour aready arenas areola areole argent argons argued arguer argues argyle argyll arhats ariary aright arilli arisen arises arkose armada armers armets armful armies arming armlet armors armory armour armpit aromas around arouse arrays arrest arrive arrows arseno arshin artery artful artier artily artist arynes ascend ascent ascots ashier ashing ashore asking asleep aspect aspens aspics aspire assail assart assays assent assert assess assets assign assist assort assume assure astern asters asthma astral astray astute asylum ataxia ataxic atokes atolls atomic atonal atoned atoner atones atonia atonic atopic atoxic atoxyl atrial atrium attach attack attain attend attest attics attire attune auburn audios audits augers aughts augite augurs augury august auklet aulete aulist aulode auntie aupair aurate aureus aurify aurora auteur author autism autist autumn auxins avails avatar avenge avenue averse averts avians aviary aviate avider avidly avoids avouch avowal avowed avower awaits awaked awaken awakes awards aweigh aweing awhile awhirl awning awoken axeman axemen axenic axhead axilla axioms axions axises axites axlike axoids axonal axonic axseed axweed axwort azalea azenes azides azines azlons azoles azolla azonal azotea azukis azured azures azymes azymia azymic baaing babble babbly babied babier babies baboon backed backer backup badder badged badger badges badman baffle bagels bagful bagged bagger baggie bagman bagmen bailed bailey bairns baited baiter bakers bakery baking balboa balder baldly baleen balers baling balked balker ballad balled ballet ballot balsam balsas bambam bamboo bammed bammer banana banded bandit banged banger bangle banish banjos banked banker banned banner banter barbed barbel barber barbie bardic barely barest barfed barfly barful barged barges barhop baring barite barium barked barker barley barman barmen barney barons barony barred barrel barren barres barrow barter baryon basalt basely basest bashed basher bashes basics basify basils basing basins basion basked basket basque basses basset basted baster bastes batboy bathed bather bathes batiks bating batlet batoid batons batted batten batter battle bauble baulks baulky bawled baying bayous bazaar beachy beacon beaded beagle beaked beaker beamed beaned beanie beards bearer beasts beaten beater beatup beauty beaver became beckon become becurl bedamn bedare bedark bedash bedaub bedbug bedded bedder bedead bedeck bedews bedewy bedims bedirt bedkey bedlam bedlar bedote bedpan bedrid bedrop bedrug bedsit bedubs beduck beduke bedung bedusk bedust bedway bedwet bedyed bedyes beebee beefed beeped beeper beetle befall befell befits befool before begets beggar begged begins begnaw begone behalf behave behead beheld behest behind behold behove beiges beings belaud belays beldam belfry belief belled belles bellow belong belows belted beluga bemaul bemire bemoan bemock bemuds bemuse bended bender bengal benign benumb benzil benzol benzyl berate bereft berets berths beryls beseem besets beside besmut besort besots besoul bespot bested bestir bestow bestud betake betide betime betoil betoss betray betrim better bevels bevies beware bewray beyond bezoar bezzle biarch biased biases bibles bicarb biceps bicker bidden bidder bidets biding bifids bifold bigamy bigger bigots bigram bigwig bijoux bikers biking bikini bilged bilges bilked bilker billed billet billow bilobe binary binded binder binged binger binges binman binmen binned binode biobag biodot bioink biomes bionic biopic biopsy biotas biotic biotin bipeds bipods bipole birded birder birdie births bisect bishop bisque bistro biters biting bitmap bitset bitted bitten bitter blabby blacks bladed blades blamed blamer blames blanch blanks blared blares blasts blazed blazer blazes blazon bleach bleary bleats bleaty blebby bleeds bleeps blench blends blenny blight blimps blinds blinks blintz blithe bloats blobby blocks blocky blokes blokey blonde blonds bloods bloody blooms bloomy blotch blotty blouse blousy blower blowsy blowze blowzy bluest bluesy bluets bluffs bluing bluish blunge blunts blurbs blurry blurts boards boardy boasts boated boater bobbed bobber bobbin bobble bobbly bobcat bobfly bocals bodega bodice bodied bodies bodily boding boffos bogeys bogged boggle bogies boiled boiler bolded bolder boldly bolero bolide bolted bolter bolton bombed bomber bonbon bonded bongos bonier boning bonked bonnet bonnie bonsai boobed booboo boodle boogie boohoo booing booked booker booksy boomed boomer boosed booses boosts booted booter booths boozed boozer boozes boozey bopped bopper borage borane borate border boreal boreen borers boring borons borrow borzoi bosoms bosons bossed bosses boston botany botchy botfly bother botnet bottle bottom boughs bought bougie bounce bouncy bounds bounty boused bouser bouses bovids bovine bovoid bowels bowers bowery bowfin bowing bowled bowleg bowler bowman bowmen bowpot bowsaw bowwow boxcar boxers boxful boxier boxing boxman boxmen boxtop boying boyish braced bracer braces bracts braggy brahma braids brails brains brainy braise braize braked brakes branch brands brandy branks brashy brassy bratty braved braver braves bravos brawls brawly brawns brawny brayed brayer brazed brazen brazes brazil breach breads breaks breast breath breech breeds breeze breezy breves brevet brewed brewer briars bribed bribee briber bribes bricks bricky bridal brides bridge bridle briefs briers briery bright brines briney brings brinks brises briths broach broads brogan brogue broils broken broker bromic bronco broncs bronze bronzy brooch broods broody brooks brooms broths brothy browed browns browse bruise brunch brushy brutal brutes bruxed bruxer bubble bubbly buboes buccal buccan buccin bucina bucine bucked bucket buckle budded budder budged budger budges budget budgie budlet buffed buffer buffet bugeye bugged bugger bugled bugler bugles builds bulbar bulbed bulbel bulged bulges bulked bullae bulled bullet bumble bummed bummer bumped bumper bunchy bundle bunged bungee bungle bunion bunked bunker bunted buoyed burble burbly burden bureau burger burghs burgle burial buried buries burlap burled burler burned burner burnet burped burqas burred burros burrow bursae bursal bursar bursas bursts burton busboy bushed bushel bushes busied busier busies busily busing busked busker buskin bussed busses busted buster bustle busway butane butene butler butted butter buttes button butyne buyers buying buyoff buyout buzzed buzzer buzzes bygone bylaws byline bypass bypath byplay byroad byssal byssin byssus byways byword cabala cabals cabbal cabbed cabins cabled cabler cables cacaos cached cacher caches cachet cachou cackle cackly cactus caddie cadets caecal caecum caeoma caesar caftan cagier cagily caging cahoot caiman cairns cajole cakier caking calami calces calico califs caliph callas called caller callow callus calmed calmer calmly calque calved calves calxes camber camels cameos camera camped camper campus canals canape canard canary cancan cancel cancer candid candle candor caners canids canine caning canker canned cannon cannot canoed canoer canoes canola canons canopy canted canter cantle canton cantor canula canvas canyon capers capite caplet capons capped capper capric capris capsid captor caract carafe carats carbon carboy carded carder cardia careen career carers caress carets cargos carhop caries carina caring carmen carnal carnyx carobs carols carpal carped carpel carper carpet carpus carrot carted cartel carter carton carved carver carves caseic casein cashed casher cashes cashew casing casino casked casket casson casted caster castes castle castor casual catchy caters catgut cation catkin catnap catnip catsup catted cattle caucus caudal caught caulis caulks causal caused causer causes cauter caveat cavern cavers caviar cavils caving cavity cavort cawing cayman ceased ceases cebids cedars ceding celery celiac cellar celled cellos celtic cement cenote censer censor census center centre cephem cerate cereal cering cerise cerium ceroid cervid cervix cesium chafed chafer chafes chaffs chaffy chains chairs chaise chalet chalks chalky champs chance chancy change chants chanty chapel chappy chards charge charms charts chased chaser chases chasms chaste chatty chaunt cheapo cheats checks cheeks cheeky cheeps cheers cheery cheese cheesy chelae chemic cheque cherry cherts cherty cherub chests chesty chewed chewer chicks chided chides chiefs childs chilis chilli chills chilly chimed chimer chimes chimps chinas chinks chintz chippy chiral chirps chirpy chisel chitin chives chocks choice choicy choirs choked choker chokes chomps choose choosy choppy choral chords chorea chored chores chorus chosen chouse chroma chrome chubby chucks chuffs chuffy chummy chumps chunks chunky church churls churly churns chutes chymic cicada cicala ciders cigars cilium cinder cinema cipher circle circus cirque cirral cirrus ciscos citers cither cities citify citing citric citron citrus civets civics clacks clades claggy claims clammy clamor clamps clangs clanks clanky claret clasps classy clause claves clawed clawer clayey cleans clears cleats cleave clefts clench cleome clergy cleric clerks clever cliche clicks client cliffs climax climbs climes clinal clinch clings clingy clinic clinks clique clitic cloaca cloaks cloche clocks cloddy clodly cloggy clomps clonal cloned cloner clones clonic clonks closed closer closes closet clothe cloths clotty clouds cloudy clouts cloven clover cloves clowns cloyed cloyer clubby clucks clucky clumps clumpy clumsy clunks clunky clutch cnidae cnidas coacts coaked coaker coaled coaler coarbs coarct coarse coasts coated coaxed coaxer coaxes cobalt cobbed cobble cobnut cobras cobweb coccus coccyx cockal cocked cocket cockle cocoas cocoon codded coddle coders codger codify coding codons coedit coelom coerce coffee coffer coffin coffle cogent cogged cognac coheir cohere cohort cohosh coiled coined coiner coitus cojoin coking colder coldly coleus collar collie colons colony colors colour colter column combat combed comber combos comedo comedy comely comers comets comfit comics coming commas commit common compel comply conchs concur condor condos confab confer confit confix conics coning conked conker conman conned consol consul convex convey convoy cooing cooked cooker cookie cooled cooler coolly cooped coopts cootie coowns copied copier copies coping copout copped copper copses copter copula corals corand corded cordon corers coring corked corker cornea corned corner cornet cornua cornum corona corpse corpus corral corset cortex corymb cosied cosier cosies cosign cosily cosine cosmic cosmos costal costar costly cotter cotton cotyla cotyle cotype cougar coughs coulee counts county couped coupes couple coupon course courts cousin covary covens covers covert covets covine coward cowboy cowers cowpie cowpox coydog coyest coyote cozeys cozied cozier cozies cozily crabby cracks cradle crafts crafty craggy craker crakes cramps crampy craned cranes cranks cranky crappy crated crater crates craton cravat craved craver craves crawls crawly crayon crazed crazes creaks creaky creams creamy crease creasy create creche credit creeds creeks creeps creepy crepes cresol cressy crests cresyl cretin crewed crewel cricks criers crimes crimps crimpy cringe crises crisis crisps crispy crista critic croaks croaky crocks crocus crofts crones crooks croons crores crotch crouch croupy crowds crowed crowns cruddy cruder cruels cruets crufts cruise crumbs crumby crummy crunch crurae crusts crusty crutch cruxes crwths crying crypts cuatro cubage cubane cubers cubify cubing cubism cubist cubits cuboid cuckoo cuddle cuddly cudgel cuffed culled cultic cultus cumene cumuli cupful cupids cupola cupped cupric cupula cupule curare curate curbed curcin curded curdle curers curfew curiae curial curing curios curium curled curler curlew cursed curser curses cursor curtly curtsy curved curves cuscus cusped cuspid cussed cusser cusses custom cutely cutest cutesy cuteys cutins cutlet cutoff cutout cutter cuttle cutups cyanic cyanid cyanin cyborg cycled cycler cycles cyclic cyclin cygnet cymbal cyneol cynics cypher cyprus cystic cytoma dabbed dabber dabble dacite dacron dactyl dadoes daemon dafter daftly dagger dahlia dainty daises dalasi daleth dalton damage damask dammed damned damner damped dampen damper damply damsel danced dancer dances dander dandle danger dangle dangly danish danker dankly dapper dapple darers daring darken darker darkly darned darner darted darter dashed dasher dashes daters dating dative datums daubed dauber daubes daunts davits dawdle dawned daybed dayfly dazing dazzle deacon deaden deader deadly deafen deafer deafly deairs dealer dearer dearie dearly dearth deaths deathy deaved deaves debark debars debase debate debeak debits debone debris debtor debuds debugs debunk deburr debuts decade decals decamp decane decant decaps decarb decare decart decays deceit decene decent decern decide decile decked deckel decker deckle declaw decoct decode decoke decors decoys decree decrew decury decyne deduce deduct deeded deejay deemed deepen deeper deeply deface defame defang defats defeat defect defend defers defied defier defies defile define deflea deflex defoam defogs deform defoul defrag defray defter deftly defuel defund defuse defuze degage degerm degree degums degunk degust deguts dehair dehorn dehort dehusk deiced deicer deices deific deinks deisms deists deject delate delays delead delete delfts delict delimb delime delink delint delist delphi deltas deltic delude deluge deluxe delved delver delves demand demaps demark demast demate demean dement demies demise demist demits demobs demoed demons demote demure demurs denars denary dengue denial denied denier denies denims denned denote denser dental dented dentil dentin denude deodar depart depend depict deploy depone deport depose depots depths depute deputy derail derays deride derive dermal dermic dermis derris desalt desand descry deseed desert design desilt desire desist desman desmid despot detach detail detain detect detent deters detest detick detort detour detube detune detusk deuced deuces devein devels devest device devils devise devoid devote devour devout dewans dewier dewily dewire dewlap dewool deworm dexter dextro dezinc dharma dharna dholes dhotis diacid diadem dialed dialer dialog dialup diaper diarch diatom dibbed dibber dibble dicers dicier dicing dicker dicots dictum dienes diesel dieses diesis dieted dieter dietic differ digest digged digger digits digram digyny diking dilate dilled dilute dimers dimmed dimmer dimple dimply dimuon dinars diners dinged dinger dinghy dining dinker dinned dinner dinted diodes dioecy dioxin diplex dipods dipole dipped dipper direct direly direst dirges dirham disarm disbar discos discus dished dishes dismal dismay disown dispel dissed disses distal disuse dither dittos ditzes divans divers divert divest divide divine diving divots diynal diynes djembe djubed doable dobras docile docked docken docker docket doctor dodder doddle dodged dodger dodges dogday dogear dogfox dogged doggie dogleg dogmas dognap dogsat dogsit dogtag doings doling dollar dolled dollop dolmen domain doming domino donair donate donkey donned donors donuts doodad doodle doomed doomer doored doozie dopant dopers dopier doping dorbug dormer dorsal dorsum dosage dosing dotage dotard dotcom doters dotier doting dotish dotted dotter dottle double doubly doubts douche doughs doughy doused douser douses dovier dovish dowels dowers dowery downed downer dowsed dowser dowses dowset doxies doxing doxxed doxxes doyens dozens dozers dozier dozily dozing drabby drably drachm drafts drafty draggy dragon drains drakes dramas draped draper drapes drawer drawls drayed drazel dreads dreams dreamt dreamy dreary dredge dreggy drench dressy driers driest drifts drills drinks drippy drivel driven driver drives droids drolly droned drones drools droops droopy dropsy droves drowns drowse drowsy drudge druggy druids drunks drupes drusen dryads dryers drying dryish dryrot dualin dually dubbed dubber dubium ducats ducked ducker ductal ducted ductor dueled dueler duffel duffle dugout dulced dulces dulcet dulled duller dumbed dumber dumbly dumdum dumped dumper dunces dunged dunite dunked duopod dupers duping duplex duress durian during dusted duster dustup dutars duties duvets dwarfs dweebs dwells dyadic dyeing dyking dynamo dynein eagles eaglet earbud earful earned earner eartag earths earthy earwax earwig easels easers easier easily easing easter eaters eatery eating ebbing ebooks ebriid echoed echoes echoey eclair ectopy ectype eczema eddied eddies edemas edemic edgers edgier edgily edging edible edicts edited editor educed educes educts eeling eerier eerily efface effect effigy effing efflux effort effuse eggars eggcup eggers eggier egging eggnog egoism egoist egress egrets eiders eighth eights eighty either ejecta ejects elapse elated elater elates elbows elders eldest elects elegit eleven elfish elicit elided elides elites elixed elixes elixir elodea eloges elogia eloign eloins eloped eloper elopes eluant eluate eluded eluder eludes eluent eluted elutes elutor eluvia elvish emails embalm embank embark embase embeds embers emblem embody emboli emboss embryo embyro emceed emcees emends emerge emerse emesis emetic emodin emojis emoted emoter emotes empire employ emulge emusic enable enacts enamel enamor encalm encamp encase encode encore encyst endear enders ending endive endows endure enemas energy enfant enfold engage engine engulf enigma enjoin enjoys enlard enlist enlive enlock enmesh enmity enolic enough enrage enrich enrobe enroll enrols enseal ensear ensign ensoul ensued ensues ensure entail enters entice entire entity entomb entrap entree envied envier envies envoys enwrap enynes enzone enzyme eolian eomyid eosine eparch epilog epimer epipod epochs eponym equals equate equids equine equips equity erased eraser erases erbium erects ergons ermine eroded erodes erotic errand errant errata erring errors erucic eructs erupts ervils escape escarp eschar eschew escort escrow escudo eskers esprit essays estate esteem esters estrum estrus etched etcher etches ethane ethene ethers ethics ethnic ethyls ethyne etymon eulogy euonym eupnea eureka eutaxy evaded evader evades evened evener evenly events everts evicts eviler evilly evince evited evites evoked evoker evokes evolve evulse exabit exacts exalts examen exarch exceed excels except excess excide excise excite excuse excyst exempt exequy exerts exhale exhort exhume exiled exiles exilic exists exited exodus exogen exonym exopod exotic expand expats expect expels expend expert expire expiry export expose expugn exsect extant extend extent extirp extoll extols extort extras exuded exudes exults exwife eyecup eyeful eyeing eyelet eyelid eyepit fabled fables fabric facade facets facial facies facing factor fadein fading faecal faeces faerie failed fainer faints fairer fairly faiths fajita fakers faking falcon fallen faller fallow falser falter family famine famish famous fanged fanjet fankle fanned fanout farads farces fardel faring farmed farmer faroff farout fascia fasted fasten faster father fathom fatted fatten fatter fatwas faucal faucet faughs faults faulty faunae faunal faunas favors favour fawned fawner faxing fazing fealty feared fearer feasts feazed feazes fecund fedora feeble feebly feeder feeler feesed feeses feezed feezes feigns feisty feline fellas felled feller fellow felons felony felsic felted female femmes femurs fenced fencer fences fended fender fennel ferret ferric ferris fervid fervor fescue fester fetish fetors fetter feudal feuded fevers fewest fezzed fezzes fiance fiasco fibbed fibber fibers fibred fibres fibril fibrin fibula fickle fiddle fiddly fidget fields fiends fierce fiesta fifths figged fights figure filets filial filing filled filler fillet fillup filmed filter filths filthy finale finals finder finely finery finest finger finial fining finish finite finned fipple firers firing firmed firmer firmly firsts fiscal fished fisher fishes fitful fitted fitter fivers fivish fixate fixers fixing fixity fixups fizzed fizzer fizzes fizzle fjords flabby flacks flaffs flails flaked flakes flakey flambe flamed flamen flames flange flanks flared flares flashy flasks flatly flaunt flavin flavor flawed flaxen flaxes flayed flayer flecks flecky fledge fleece fleecy fleets flench flense fleshy flexed flexes flexor flicks fliers flight flimsy flinch flings flints flinty flippy flirts flirty floats floaty flocks flocky floods floors floppy floral floret florin flossy flours floury flouts flowed flower floxed floxes fluent fluffs fluffy flugel fluids fluked flukes flukey flumed flumes flumps flunks flunky flurry fluted fluter flutes fluxed fluxer fluxes flybys flyers flying flyoff flyway foaled foamed foamer fobbed fodder foetal foetid foetus fogash fogbow fogdog fogeys fogged fogies foible foiled foists foisty folate folded folder foldup foleys folios folium folksy follow foment fonded fonder fondle fondly fondue fooled footed footer footsy foozle forage forays forbid forced forcep forcer forces forego forest forged forger forges forget forgot forint forked forker formal format formed former formic formin fornix forsee fortes forums fossil foster fought fouled fouler founds fourth foveae foveal fowler foxier foxily foxing foyers fozier fracas fracks framed framer frames francs franks fratch frater frauds frayed freaks freaky freely freest freeze frenzy freons fresco fretty friars friary friday fridge friend frieze fright frigid frijol frills frilly fringe fringy frisks frisky frizzy frocks froggy frolic fronds fronts froren frosts frosty froths frothy frowns frowny frowst frowsy frowzy frozen frugal fruits fruity frumps frumpy fryers frying frypan fucose fuddle fudged fudges fueled fueler fuffed fuffle fugacy fugued fugues fuhrer fukiic fulfil fulgur fuller fumble fumier fuming funded funder fundus fungal fungus funked funker funnel funner furane furans furies furled furler furred furrow fusees fusels fusers fusing fusion fussed fusser fusses futile futons future fuzing fuzzed fuzzes gabbed gabber gabble gabbro gabled gabler gables gadfly gadget gaelic gaffed gaffer gaffes gagged gagger gaggle gaging gaiety gained gainer gainly gaited gaiter galaxy galena galled galley gallic gallon gallop gallow galoot galore galosh gambit gamble gambol gamely gamers gamest gamete gamier gaming gammas gamuts gander ganefs ganevs ganged ganofs gantry gaoled gaoler gaping gapped gapper garage garbed garble garden gargle garish garlic garner garnet garret garter gashed gasher gashes gasify gasket gaslit gasped gasper gassed gasser gasses gastly gateau gather gating gators gauche gauged gauges gaunts gauzed gauzes gavage gavels gawked gawker gawped gawper gayest gayety gazebo gazers gazing gazump geared geckos geeked geisha gelate gelato gelcap gelded gelder gelled gelose gemmed gender genera genets genial genies genius genoas genome genres gentle gently gentry geodal geodes geodic geoids geomap geonym geotag gerbil getter geyser ghetto ghosts ghouls giants gibbon giblet gidjak gifted gigged giggle giggly gijaks gilded gilder gimbal gimped ginger ginkgo ginned girded girder girdle girlie girned girnel girner girths gismos givens givers giving gizmos glades gladly glamor glamps glance glands glared glares glassy glazed glazes gleams gleamy gleans gleeks gleets gleety glibly glided glider glides glints glinty glioma glitch glitzy gloams gloats global globby globed globes glooms gloomy glossy gloved glover gloves glowed glower glozed glozes gluers gluier gluing glumly gluons gluten glycan glycic glycol glyphs gnarls gnarly gnarrs gnatty gnawed gnawer gneiss gnomes gnomic gnomon gnoses gnosis goaded goalie goanna goatee gobbed gobber gobbet gobble gobies goblet goblin godson gofers goggle goings goiter goitre golden golfed golfer gonads goners gonged gonifs gonofs goober goodby goodie goofed google googly googol gooier goosed gooses goozle gopher gorged gorges gorget gorgon gorier gorily goring gospel gossip gotcha gothic gotten gouged gouger gouges goundy gourde gourds govern gowned grabby graced graces graded grader grades grafts graham grails grains grainy grammy grands granny grants granum grapes graphs grasps grassy grated grater grates gratis graved gravel graven graver graves gravid grayed grayer grazed grazer grazes grease greasy greats greedy greens greets greyed greyer griefs grieve grille grills grimed grimes grimly grinch grinds griots griped griper gripes grippy grisly gritty groans grocer groggy groins gromet grooms groove groovy groped groper gropes grotto grotty grouch ground groups grouse grouts groved grovel grover groves grovet growed grower growls growly growth grubby grudge gruels gruffs gruffy grumps grumpy grunge grungy grunts guanos guards guavas guests guffaw guggle guided guider guides guilds guiled guiles guilts guilty guinea guises guitar guitjo gulags gulden gulled gullet gulley gulped gulper gumbos gummed gundog gunite gunman gunmen gunned gunner gunter gurgle gurgly gurner gurney gushed gusher gushes gusset gusted gutted gutter guzzle gypped gypper gypsum gyrate habits hacked hacker hackle hadean hadron haemic haemin hafter hagged haggis haggle haglet hailed hairdo haired haitch hakata halide halite hallow hallux haloed haloes halted halter halved halver halves hamaxe hamlet hammed hammer hamper handed hander handle hangar hanged hanger hangup hanker hankie happed happen hapter haptic harass harbor harden harder hardly hardup harems harked harken harlem harlot harmed harmer harped harper harrow hashed hashes hassle hasted hasten hastes hatbox haters hatful hating hatpin hatred hatted hatter hauled hauler haunch haunts hauyne havens having hawing hawked hawker hawser hawses haybox haycap hayers haying haymow hazard hazels hazers hazier hazily hazing hazmat headed header headon healds healed healer health heaped heaper hearer hearse hearth hearts hearty heated heater heaths heathy heaved heaven heaver heaves heckle hectic hedged hedger hedges heeded heehaw heeled hefted hefter heifer height heired heists helios helium hellos helmed helmet helped helper hemmed hemmer hennas henrys herald herbal herbed herber herded herder hereby herein hereof hereon heresy hereto hermit hernia heroes heroic heroin herons herpes hewers hewing hexane hexene hexing hexone hexose hexyne heyday hiatal hiatus hiccup hickey hidden hiders hiding higher highly hijabs hijack hijinx hikers hiking hilled hinder hinged hinges hinted hinter hiphop hipped hipper hippie hippos hirers hiring hissed hisser hisses hither hitman hitmen hitter hiving hoagie hoards hoarse hoaxed hoaxer hoaxes hobbit hobble hobday hobnob hocked hockey hoeful hoeing hogged hogger hogtie hoists holden holder holdup holier holing holism holler hollow homage hombre homely homers homier homily homing honers honest honeys honing honked honker honors honour hooded hoodie hoodoo hoofed hoofer hooked hooker hookup hooped hooray hooted hooved hooven hoover hooves hoping hopped hopper hopple hordes horned hornet horrid horror horsed horses horsey hosers hosier hosing hostas hosted hostel hotair hotbed hotbox hotdog hotels hotpot hotrod hotted hotter hottub hounds hourly housed houses hovels hovers howard howled howler howtos hubbed hubber hubble hubbub hubcap hubris huddle huffed hugely hugest hugged hugger hulked hulled huller humane humans humble humbly humbug humite hummed hummer hummus humors humour humous humped humper humpie humvee hunchy hunger hungry hunker hunted hunter hurdle hurled hurler hurrah hurted hurter hurtle hushed hushes husked husker huskie hustle hutted hutzpa hyaena hyalin hybrid hybris hydras hydric hyenas hylids hymens hymnal hymned hymner hyphen hyping iambic ibexes ibises iceage icebox icecap icedam iceman icemen icicle iciest icings ickier iconic ideals idents idiocy idioms idiots idlers idlest idling idylls igloos ignite ignore iguana iliums illite illium illume imaged imager images imagos imbeds imbibe imbued imides immune immure impact impair impala impale impart impede impels impend imping impish implex import impose improv impugn impure inanes inborn inbred incant incase incell incest inched incher inches incise incite income incubi inculp incurs indeed indent indian indict indies indigo indite indium indole indoor indraw indrew induce induct infamy infant infect infers infest infill infirm inflow influx infold inform infuse ingest ingots inhale inhole inimic inject injoin injoke injure injury inkier inking inkjet inkpad inkpot inlaid inland inlaws inlays inlets inline inlock inmate inmesh inmixt inmost innate inning inodes inputs inroad inrush insane inseam insect insert insets inside insist insitu insole instar instep insult insure intact intake intend intent intern intext intone intort intron intuit inturn inulas inulin inured inures invade invect invent invert invest invite invivo invoke inward inwell inwick inwove iodide iodine iodise iodism iodite iodize iodous iolite ionise ionize ionone iotize ipecac iphone irater ireful irenic iridis irises iritic iritis irking ironed ironer ironic ironym irreal ischii island islets isobar isogon isohel isomer isonym isopod issued issuer issues italic itched itches itself jabbed jabber jackal jacked jacket jading jadish jagged jaguar jailed jailer jailor jalopy jamjar jammed jammer jampot jangle jangly japans jarful jargon jarred jasper jaunts jaunty jawing jazzed jazzes jeered jeerer jehadi jehads jejuna jejune jejuni jelled jellos jembes jerked jerker jersey jested jester jetlag jetted jetway jewels jibers jibing jigged jiggle jiggly jigsaw jihadi jihads jilted jilter jingle jingly jinked jinker jinxed jinxer jinxes jitter jivers jivier jiving jobbed jobber jockey jocose jocund jogged jogger joined joiner joints jointy joists jojoba jokers joking jolted jolter joshed josher joshes jostle jotted jotter joules jounce jouncy jousts jovial jowled jowler joyful joying joyous joypop judged judger judges jugate jugful jugged juggle jugums juiced juicer juices juicey jujube juking juleps julies jumble jumbly jumped jumper jungle junior junked junker junket juntas juried juries jurist jurors juster justle justly jutted kababs kabala kabals kabaya kabbal kabobs kaftan kahuna kaiser kankar kaolin kaonic kappas karate karats karite karmas karmic karsts karyon kasher katals kayaks kazoos kebabs keeked keeker keeled keened keener keenly keeper keloid kelped kelper kelpie kelvin kennel kepped kerned kernel ketols ketone ketose kettle kevlar keyfob keying keylog keypad keyset keyway khakis kibble kibitz kicked kicker kidded kidder kiddie kiddos kidnap kidney killed killer kilned kilted kilter kimono kinase kinder kindle kindly kingly kinked kiosks kipper kirtle kissed kisser kisses kiting kitten kittle klutzy knacks knarle knarls knarly knarry knaurl knaurs knaves kneads kneels knells knifed knifes knight knives knobby knocks knolls knolly knotty knower knowns knubby knurle knurls knurly knurry koalas koodoo kooked koruna kosher kronas krones kroons kudzus kungfu kvetch kwacha kwanza laager labels labial labile labium labors labour lacers lacier lacily lacing lacked lackey lactic lacuna ladder laddie ladies lading ladled ladles lagers lagged lagger lagoon lahars laired lakers lambda lambed lamely lament lamest lamina lanced lancer lances lancet landed lander langue langur lanker lankly lanugo lapdog lapels lapful lapped lapsed lapses laptop larded larder larger larges largos lariat larked larvae larval larvas larynx lasers lashed lasher lashes lasses lassie lassos lasted lastly lately latent latest lathed lather lathes latino latite latkes latter lattes lauded laughs launch laurel lavage lavash laveer laving lavish lawful lawman lawmen lawned lawyer laxest laxism laxist laxity layers layery laying layman laymen layoff layout layups lazier lazies lazily lazing leaded leaden leader leafed league leaked leaker leaned leaner leanly leanto leaped leaper learns learnt leased leaser leases leasow leaved leaven leaver leaves lecher leches lectin ledged ledger ledges leered leeway lefter leftie legacy legate legend legged legion legman legmen legume lemons lemony lemurs lender length lenite lenses lentil leones lepers leptin lepton lesion lessee lessen lesser lesson lessor lester lethal letter leveed levees levels levers levied levier levies levity lewder lewdly lexeme liable liaise libate libels libido lichen licked licker lidded lifers lifted lifter ligand ligase ligate lights lignin ligule likely likens likest liking lilacs lilies lilted limbed limber limbic limier liming limits limned limped limper limpet limpid limply linage linden lineal linear linens liners lineup linger lingua lining linked linker linkup linnet lintel lionet lionly lipase lipids lipoic lipoma lipped liquid liquor lirked lisbon lisped lisper listed listen litany liters lithic litmus litres litter little lively livens livers livery living lixive lizard llamas loaded loader loafed loafer loaned loaner loathe loathy loaves lobate lobbed lobber lobing lobule locale locals locate locked locker locket lockup locule loculi locust lodged lodger lodges lofted logged logger logics logins logjam logoff logout loiter lonely loners longae longed longer loofah looked looker lookup loomed looney loonie looped loosed loosen looser looses looted looter loping lopped lopper lorate lordly lories losers losing losses lotion louder loudly lounge loused louses louver louvre lovage lovely lovers loving lowers lowest lowfat lowlit lubing lucent lucite lucked luffas luffed lugged lugger lulled lumbar lumber lumens lummox lumped lunacy lunars lunary lunate lunged lunges lunier lunies lupeol lupine lupins lurers luring lurked lurker lusher lushly lusted luster lustre luteal lutein luteum lutist lutite luxate luxury lyases lychee lycras lymphs lymphy lynxes lyrate lyrics lyrist lysate lysine macaws mackle macros macula macule madame madams madden madder madefy madman madmen madras mafias mafics maggot maglev magmas magnet magnon magnum magpie maiden mailed mailer maimed maimer mainly majors makers makeup making malady malice malign mallee mallet mallow malted mambas mambos mammal mammon manage manats manger mangey mangle mangos maniac manias manics manila manned manner manors mantel mantis mantle mantra manual manure maples mapped mapper maraca maraud marble marbly margin marina marine markas marked marker market markup marlin marmot maroon marque marred marrer marrow marshy marten martin martyr marula marvel masada masala mascot mashed masher mashes mashup masked masker masons masque massed masses massif masted master mastic maters mateys mating matrix matron matted matter mattes mature mauled mauler mauves mavens mavins maxima maxims maybug mayday mayfly mayhap mayhem mayors mazers mazier mazily mazing mbilas mbiras meadow meager meagre meaner meanie meanly measly meatus medals meddle medfly medial median medias medics medium medius medley medusa meeker meekly meeter melded melees mellow melody melons melted melter member memoir memory menace menage mended mender menial menses mental mentor meotic meowed meower mercer merely merest merged merger merges mering merits merman mermen meront meshed mesher meshes mesons messed messes metals meteor meters method methyl metres metric metros mettle mewing miasma miasms mickey micron midair midday midden middle midges midget midgut midrib midway miffed mighty milder mildew mildly milieu milked milker milled miller millet milord mimeos mimics miming mimosa minced mincer minces mindat minded minder miners mingle minify minima minimi minims mining minion minnow minors minted minter minuet minute minxes minyan miosis mirage miring mirror misadd misaim miscue miscut misdid misers misery misfed misfit mishap miskey mislay misled mislit mispay mispen missal missay missed misses missus misted mister mistle mistry misuse miters mitier mitral mitred mitres mitted mitten mixers mixing mixups mizzly mnemic mnemon moaned moaner moated mobbed mobber mobile mochas mocked mocker mockup modals modded models modems modern modest modify modula module moduli modulo moguls mohair mohars mohawk mohels moiety molars molded molest molted molten moment mommas monads monday moneys monger mongol monies monism monkey monoid monops months mooing moolah mooned moored mooted mooter mopeds mopers mopery mopier moping mopish mopped mopper moppet morale morals morass morays morbid morels morgue morons morose morphs morrow morsel mortal mortar morula mosaic mosque mossed mosses mostly motels mother motifs motile motion motive motley motors mottle mottos moujik moulds mouldy moulin moults mounds mounts mourns moused mouser mouses mousey mousse mouths mouthy movers movies moving mowers mowing mucins mucked mucker mucoid mucosa mucous mucros mudcap muddle mudlog muesli muffed muffin muffle mugful mugged mugger mujiks mukluk mulish mulled muller mullet mumble mumbly munged munger munify munite muonic muppet murals murder murine murmur muroid murray muscle muscly musers museum mushed musher mushes musics musing muskeg musket muskox muslin mussel muster mutant mutate mutely mutest muting mutiny mutism mutter mutton mutual muzhik muzjik muzzle mycoin myelin myogen myomas myonym myopia myopic myosin myotic myotis myriad myrtle myself mystic mythic mythos myxoid myxoma nabbed nabobs nachos nagged nagger naiads nailed nailer nairas naiver nakfas namely namers naming nanobe napkin napped napper narrow nasals nation native natter nature naught nausea navajo navels navies nazism neaped nearby neared nearer nearly neaten neater neatly nebula necked necker necral nectar needed needer needle negate neighs nekton nelson nepers nephew nerved nerves nested nester nestle netcom nether netted netter nettle neumes neural neuron neuter newbie newels newest newish newton ngwees niacin nibbed nibber nibble nicely nicest nicety niches nicked nickel nicker nickle nieces niello niggly nights nimble nimbly ninety ninjas ninths nipped nipper nipple nitric nitryl nitwit nobled nobler nobles nobody nocked nodded nodder nodule noggin noised noises noload nomads nonage nonane nonart nonces noncop noncut nondog nonegg nonego nonene nonfan nonfat nonfed nonfee nonfit nongay nongod nonjew nonjob nonlab nonmud nonoil nonpro nontax nonuse nonyne noodle noosed nooser nooses nordic norite normal normed nosean noseys nosier nosily nosing nosode notary notate notice notify noting notion notist nougat nought novels novice noways nowise nozzle nuance nubbed nubble nubbly nuclei nudest nudged nudges nudies nudify nudism nudist nudity nugget nuking numbed number numbly nursed nurser nurses nutjob nutlet nutmeg nutted nutter nuzzle nylons nymphs oafish oaring obduce obduct obeyed obeyer object objure oblast oblate oblige obloid oblong oboist obsess obtain obtuse obvert occult occupy occurs oceans ocelot ochers ochrea ochres octals octane octant octave octene octets octopi octose octyne ocular oculus oddest oddity odessa odious odists odonym odored odours oecist oedema oeuvre offcut offend offers office offset oghams oglers ogling ogress oikist oilcan oilers oilier oiling oilman oilmen oilrig oinked okayed oldest oldies oleate olefin olives omegas omelet omnium onchip oneoff oneway onions oniony online onload onsets onsite onward onyxes oocyst oocyte oodles oogamy oohing ooidal oolite oolith oology oolong ootids ootype oozers oozier oozily oozing oozoid opaque opcode opened opener openly operas operon opiate opined opines opioid opiums oppose optics opting option oracle orally orange orated orates orator orbits orchid ordain ordeal orders organs orient origin oriole ornate ornery orogen oronym orphan oscars oscula osmium osprey ossein ossify osteon ostler others otitis otters ouijas ounces ousted ouster outage outbat outbeg outbet outbid outbox outbud outbuy outcry outdid outers outfit outfly outfox outgas outgun outing outjet outjut outlaw outlay outled outlet outlie outman output outran outrap outrig outrun outsat outsaw outsee outset outsit outwit ovated ovates overdo overly overos ovines ovoids ovular ovules owlery owlets owlier owling owlish owners owning oxalic oxbane oxbird oxbows oxboys oxcart oxeyes oxford oxherd oxhide oxides oxidic oxlike oxlips oxslip oxtail oxters oxygen oxymel oxyopy oyster ozalid paanga pablum pacers pacify pacing packed packer packet padded padder paddle padres paella pagans pagers paging pagoda pained paints painty paired pajama palace palate palely palest palled pallet pallid pallor palmar palmed palter paltry pampas pamper pandas pander panels panfry panful panics panini panino panned panted panter pantry papacy papaya papers papery pappus papule papyri parade parcel parchy pardon parent parers parged parges parget pariah paring parish parity parkas parked parker parlay parley parlor parody parole parral parrot parsec parsed parser parses parson parted partly pascal passed passer passes pastas pasted pastel pastes pastey pastor pastry pataca patchy patent pathos patina patine patios patrol patron patted patter paunch pauper paused pauses paving pawing pawned paxwax payday payees payers paying payoff payola payout peaces peachy peaked pealed peanut peapod pearls pearly pebble pebbly pecans pecked pecker pecten pectic pectin pedals pedant pedate peddle peeked peeled peeler peeped peeper peered peeved peever peeves peewee pegbox pegged pegleg pelite pellet pelted pelter pelvic pelvis pencil pended penile penman penmen penned penner penpal pentup pentyl penult penury people pepful pepped pepper pepsin peptic perils period perish perked permed permit person perter pertly perula perule peruse pester pestle pestos petals petard peters petite petnap petrel petrol petted pewees pewits pewter phased phases pheese pheeze phenol phenom phenyl pheons phizes phizog phlegm phloem phobia phobic phoned phones phoney phonic phonon phooey photic photon photos phoxim phrase phylae phylum phymas phytic pianos piazza pickax picked picker picket pickle pickup picnic picric piddle piddly pieced pieces pieing pieman piemen pierce pietas pietic piffle pigeon pigged piglet pigout pigpen pigsty pikers piking pilafs pilate pileup pilfer piling pillar pillow piloid pilose pilots pimped pimple pimply pincer pineal pinene pinged pinger pingle pingos pining pinion pinked pinken pinker pinkey pinkie pinkly pinnae pinned pintos pinups pinyin pinyon pipers piping pipits pippin piqued piques piquet piracy pirate pisoid pistil pistol piston pitchy pithed pithes pitied pitier pities pitman pitmen pitons pitsaw pitted pitter pivots pixels pixies pixmap pizzas placed placer places placid plague plaids plains plaits planar planed planer planes planet planks plants plaque plashy plasma plasty plated plater plates playas played player plazas pleads please pleats plebby pledge pleion plenty pleura plexor plexus pliant pliers plight plinks plinth ploids ploidy plonks plooks plooky plough plouks plouky plover plowed plower plucks pluckt plucky pluffs pluffy pluggy plugin plumbs plumed plumes plummy plumps plunge plunks plunky plural pluses plushy pluton plying pocked pocket podand podded podium podsol podzol poetic poetly poetry points pointy poised poises poison pokers pokier poking polars poleax police policy poling polios polish polite polkas pollax polled pollen pollex polyol polyps pomade pomelo pommel pompom pomsky poncho ponder ponies poodle poofed poofer poohed pooled pooped pooper poorer poorly popest popeye popgun poplar poplin popoff popped popper popups poring porked porker poroma porose porous portal ported porter portly posada posers poseur poshed posher posies posing posits posses posset possum postal posted poster postil postop potage potash potato potboy poteen potent potful pother potica potion potman potmen potpie potted potter pottle pouffe poults pounce pounds poured pourer pouted pouter powder powers powwow poxier praise prance pranks prated prater prates prawns praxis prayed prayer preach preamp prearm prebuy precut predry preens prefab prefer prefit prefix premed premet premix preons prepay preppy preset pretan pretax pretty prevue prewar preyed priced pricer prices pricey pricks prided prides priest primal primed primer primes primly primps prince prints prions priors priory prisms prismy prison prissy prized prizes probed prober probes profit prolix prolog promos prompt proner prongs proofs propel proper propyl prosed proton proved proven prover proves prowls prudes pruned pruner prunes pryers prying psalms psalmy psions psyche psycho psychs pterin ptosis public pucker puddle puddly pueblo puffed puffer puffin pugils pukers puking pulled puller pullet pulley pullup pulped pulper pulpit pulsar pulsed pulser pulses pumelo pumice pummel pumped pumper punchy pundit punier punish punned punner punted punter pupate pupils pupped puppet pureed purees purely purest purfle purfly purged purger purges purify purine purism purist purity purlin purple purply purred pursed purser purses pursue purvey pushed pusher pushes pushup pusses putoff putrid putsch putted putter puttos puzzle pyemia pyemic pyjama pylons pylori pyrene pyrite pyrone pyrope python pyuria qabala qabals qabbal qanats qindar qintar qiviut quacks quacky quaffs quails quaint quaked quaker quakes qualms qualmy quanta quarks quarry quarts quartz quasar quaver qubits qubyte queasy queazy queens queers queery quelch quells quench quests quetch queued queuer queues qugate quiche quiets quiffs quight quills quilly quilts quince quinic quinoa quinol quinsy quints quippy quired quires quirks quirky quited quiver quizzy qulliq quorum quotas quoted quotee quoter quotes qutrit rababs rabbet rabbis rabbit rabble rabies raceme racers rachet rachis racial racier racily racing racism racist racked racker racket racoon radars radial radian radios radish radium radius radome radons radula raffia raffle rafted rafter ragbag ragers ragged raging ragout ragtag ragtop raided raider railed rained raised raiser raises raisin rakers raking rakish ramble ramets ramify ramjet rammed rammer ramose ramped ramrod rancid rancor random ranged ranger ranges ranids ranked ranker ransom ranted ranter rapers raphid rapids raping rapist rapped rappel rapper raptly raptor rarefy rarely rarest rarify raring rarity rascal rasher rashes rashly rasped rasper raster raters rather ratify rating ration ratios ratted ratter rattle rattly ratton raucid raunch ravage ravels ravens ravers ravine raving ravish rawest raxing raying rayons razeed razees razers razing razors razzed razzes reachy reacts readds reader readme reagin reaked reaker realer really realms realty reamed reamer reaped reaper reared rearms reasks reason reasts reaved reaver reaves reavow rebabs reback rebags rebait rebake rebale rebans rebars rebase rebate rebath rebell rebels rebids rebill rebind rebins rebite rebled reblog reboil rebond rebook reboot rebops rebore reborn rebred rebuff rebuke reburn rebury rebute rebuts rebuys recall recane recant recaps recase recast recede recent recess rechew recipe recite recked reckon reclad reclip reclog recoal recoat recock recode recoil recoin recomb recons recook recool recopy record recork recoup rectal rector rectum recure recurl recurs recuse recuts redact redate redden redder redeal redeem redefy redeny redeye redial redink redips redipt redock redone redons redose redrag redraw redrew redrug redubs reduce reduct redyed redyes reecho reedit reefed reeked reeker reeled reeler reemit reests reeves reface refect refeed refers refile refill refilm refind refine refire refits reflag reflex reflip reflog reflow reflux refold reform refret refuel refuge refund refurl refuse refute regain regale regard regave regear regels regent reggae regild regime region regive reglow reglue regrab regret regrew regrip regrow rehabs rehang reharm rehash reheap rehear reheat reheel rehems rehide rehire rehome rehone rehook rehung reiced reices reigns reined reinks reject rejets rejigs rejogs rejoin rekeys reknit reknot relace relaid relast relate relays relent relics relict relied relief relier relies reline relink relish relist relive reload reloan relock relogs relook remade remail remain remake remand remaps remark remate remedy remeet remelt remend remesh remind remine remint remiss remits remixt remold remote remove remows renail renals rename render renege renest renets renews rennet rennin renown rental rented renter reoils reopen repace repack repage repaid repair repark repass repave repays repeal repeat repeel repegs repels repens repent reperk repile repine repins repipe replan replay repled replot replow replug repoll repops report repose repost repots repour repray repump repute rerack rerape reread rerent reroll reroof reroot reruns resaid resail resale resand resave resawn resaws resays rescan rescue reseal reseat resect reseed reseek resell resend resent resets resewn resews reshim reship reshod reshoe reshot reshow reside resift resign resins resiny resist resits resize reskew reskim resnap resnub resoak resods resoil resold resole resorb resort resown resows respan respin respot respun rested restem restep rester restir result resume resums retack retags retail retain retake retape retaps retard retask reteam retear reteed retees retell retest rethaw retied reties retile retill retilt retime retina retint retire retold retook retool retore retorn retort retour retrap retree retrim retune return retuse retype reurge reused reuses revamp reveal revels reverb revere revers revert revery review revile revise revive revoke revolt revote revues revved rewalk reward rewarm rewarn rewash reweds reweld rewets rewind rewipe rewire reword rework rewove rewrap rezero rezips rezone rhemes rhesus rhetic rhetor rheums rheumy rhexes rhexia rhexis rhinos rhombi rhombs rhotic rhymed rhymer rhymes rhythm ribbed ribber ribbon ribeye riblet ribose ricers richer riches richly ricing ricked ridded ridden riddle riders ridged ridges riding rifled rifler rifles rifted rigged rights righty rigids rigors rigour riling rilles rillet riming rimmed rimose rinded ringed ringer rinked rinker rinsed rinser rinses rioted rioter ripely ripens ripest ripoff ripped ripper ripple ripply risers rising risked risker risque ritual rivals rivers rivets riving riyals roadie roamed roamer roared roarer roasts robabs robbed robber robbin robing robins robots robust rocked rocker rocket rococo rodded rodder rodent rodeos roding rogers rogues roiled rolled roller romped romper roofed roofer rooked rookie roomed roomer roosts rooted rooter ropers ropier ropily roping rosary rosier rosily rosins roster rotary rotate rotgut rotons rotors rotted rotten rotter rotund roughs roughy rounds roused rouses routed router routes rovers roving rowers rowing royals rubabs rubbed rubber rubble rubefy rubied rubies rubles ruboff rubout rubric ruckus rudder rudely rudest rudite rueful ruffed ruffle ruffly rufous rugged rugger rugose rugrat ruined rulers ruling rumbas rumble rumbly rummer rumors rumour rumped rumple rumply rumpus runins runnel runner runoff runway rupees rupiah rushed rusher rushes russet rusted ruster rustic rustle rutile rutted sabers sabino sabled sables sabred sabres sachet sacked sacker sacral sacred sacrum sadden sadder saddle sadism sadist safari safely safest safety sagely sagest sagged sagger sagier sailed sailer sailor saints salaam salads salame salami salary saline saliva sallow salmon salons saloon salted salter salute salved salver salves salvia samara sambar sambas samekh sample sandal sanded sander sanely sanest sanity sansus sanzas sapped sapper sarape sashay sashed sashes sassed sasses sateen sating satins satiny satire satrap satyrs sauced saucer sauces saunas sautes savage savant savers saving savior savors savory savour sawers sawfly sawing sawman sawmen sawpit sawyer sayers sayest saying scabby scalar scalds scaled scaler scales scalps scampi scamps scanty scapes scarab scarce scared scarer scares scarey scarfs scarps scarry scathe scatty scenes scenic scents schema scheme schism schist schizy schlep school schorl schtik schwas scilla sclera scoffs scolds scolex sconce scones scoops scoots scoped scopes scorch scored scorer scores scoria scorns scotch scours scouts scowls scrags scrape scraps scrawl scream screed screen screes screws screwy scribe scried scries scrimp scrims scrips script scroll scrota scrubs scruff scrums scryer scubas scuffs sculks sculls sculpt scummy scurry scurvy scutes scutum scuzzy scythe seabag seabed seadog seafog seahog sealed sealer seaman seamed seamen seamer seance searat search seared searer season seated seater seaway secant seccos secede secern second secret sector secund secure sedans sedate sedges seduce sedums seeded seeder seeing seeker seemed seemly seeped seesaw seethe segued segues seismo seitan seiten seized seizer seizes seldom select selfie seller selsyn selves semens senary senate sender senile senior sennas senora senors sensed senses sensor sentry sepals sepias sepoys sepsis septae septal septet septic septum sequel sequin seracs serail serape seraph serene serest serges serial series serifs serine sering sermon serous serums serval served server serves sesame sestet setoff settee setter settle settop setups sevens severe severs sewage sewers sewing sexier sexily sexism sexist sextan sextet sexton sexual shabby shacks shaded shader shades shadow shafts shaggy shaken shaker shakes shaled shales shaley shaman shamed shames shanks shanty shaped shaper shapes shards shared sharer shares sharks sharps sharpy shaved shaven shaver shaves shawls sheafs shears sheath sheave sheens sheeps sheers sheets sheikh sheiks shells shelly shelve sheqel sherif sherpa sherry shewed shield shiest shifts shifty shills shimmy shined shiner shines shinto shinty shires shirks shirts shiver shlock shmear shmoes shoals shoaly shocks shoddy shoers shofar shogun shooed shooks shoots shored shores shorts shorty should shouts shouty shoved shovel shover shoves showed shower shrank shreds shrewd shrews shriek shrift shrike shrill shrimp shrine shrink shrive shroud shrubs shrugs shrunk shtick shtiks shucks shunts shutin shutup shyers shyest shying sicced sicked sicken sicker sickle sickly sickos siding sidled sidler sidles sieged sieges sienna sierra siesta sieved sieves sifted sifter sighed sigher sights sigmas signal signed signee signer signet signor sikidy silane silent silica silken silted silvan silver simian simile simmer simper simple simply sinews sinewy sinful singed singer singes single singly sinker sinned sinner sinoid sinter siphon sipped sipper sirens siring siskin sister sitars sitcom siting sitins sitter situps sixers sixgun sixing sixmos sixths sizars sizers sizing sizzle skaith skated skater skates skeely skelps sketch skewed skewer skibob skiddy skidoo skiers skiffs skiing skijor skills skimps skimpy skinks skinny skirls skirts skulks skulls skunks skunky slacks slaggy slalom slangs slangy slants slated slater slates slatey slaved slaves slavic slayed slayer sleave sleaze sleazy sledge sleeks sleeps sleepy sleets sleety sleeve sleezy sleigh sleuth slewed sliced slicer slices slicks slider slides sliest slight slimed slimes slimly slings slinks slinky slippy slipup slitty sliver slobby slogan sloops sloped sloper slopes sloppy sloshy sloths slouch slough sloven slowed slower slowly sludge sludgy sluice slummy slumps slumpy slurps slurry slushy slyest smacks smalls smarms smarmy smarts smarty smears smeary smells smelly smelts smiled smiler smiles smiley smirch smirks smirky smiter smites smiths smithy smocks smoggy smoked smoker smokes smokey smooch smooth smudge smudgy smugly snacks snafus snaggy snails snaily snaked snakes snakey snappy snared snarer snares snarfs snarks snarky snarls snarly snatch snazzy sneaks sneaky sneers sneeze sneezy snicks snider sniffs sniffy sniped sniper snipes snippy snitch snivel snobby snoeks snoods snoops snoopy snoots snooty snooze snoozy snopes snored snorer snores snorts snorty snotty snouts snouty snowed snubby snudge snuffs snuffy snugly soaked soaker soaped soaper soared soarer sobbed sobber sobers sobors soccer social socked socket sodded sodden sodger sodium sodomy soffit softas soften softer softie softly sogged soiled soiree solace solder solely solemn solids soloed solute solved solver solves somber sombre somite somoni sonars sonata sondes sonics sonify sonnet sooner sooted soothe sooths sophta sopite sopors sopped sopper sorbed sorbet sorbic sordid sorely sorest sorgho sorgos sorrel sorrow sortal sorted sorter sortie sought souled sounds souped source soured sourer sourly sowers sowing sozzle sozzly spaced spacer spaces spacey spaded spader spades spadix spalls spammy spanks spared sparer spares sparks sparky sparry sparse spasms spathe spawns spayed speaks spears specie specks specky speech speeds speedy spells spends sperms spermy spewed spewer sphene sphere sphery sphinx spiced spicer spices spicey spider spiels spiers spiffs spiffy spigot spiked spiker spikes spills spinal spined spinel spines spinet spinny spinon spiral spirea spired spires spirit spirts spited spites splash splats splays spleen splice spline splint splits splosh spoils spoilt spoken spokes sponge spongy spoofs spoofy spooks spooky spools spoons spoors spored spores sporic sports sporty spotty spouse spouts sprags sprain sprang sprats sprawl sprays spread sprees sprier sprigs spring sprint sprite sprits spritz sprout spruce sprucy sprung spryer spryly spumed spumes spunky spurge spurns spurry spurts sputum spying squabs squads squall square squash squats squawk squeak squeal squibs squids squint squire squirm squirt squish sringa stable stably stacks staffs staged stager stages stains stairs staked stakes stalag staled staler stales stalks stalky stalls stamen stamps stance stanch stands stanol stanza stapes staple starch stared starer stares starry starts starve stasis stated staten stater states static statin statue status staved staves stayed stayer steady steaks steals steams steamy steeds steels steely steeps steers steins stemmy stench stenos stents steppe stepup stereo sterna sterns sterol stevia stewed sticks sticky stiffs stifle stigma stills stilly stilts stilty stings stingy stinks stinky stints stipes stitch stived stiver stives stocks stocky stodgy stogey stogie stoics stoked stoker stokes stolen stoles stolid stomal stomas stomps stoned stoner stones stoney stooge stools stoops storax stored stores storey storks storms stormy stoups stoury stoves stowed strain strait strand straps strata straws strawy strays streak stream street stress strewn strews strick strict stride strife strike string stripe strips stript stripy strive stroam strobe strode stroke stroll stroma strong strops strove strown struck strums strung struts stubby stucco studio stuffs stuffy stumps stumpy stunts stunty stupas stuped stuper stupes stupid stupor sturdy styful stylar styled styler styles stylet stylia stylus stymie styrax styrol suaver subahs subbed subdue sublet submit subnet suborn subpar subsea subset subtle subtly suburb subway succor sucked sucker suckle suckup sudate sudden sudsed sudser sudses sueded suedes suffer suffix sugars sugary suited suiter suites suitor sulcus sulfas sulfur sulked sulker sullen sultan sultry sumach sumacs summed summer summit summon sunbed sunbow sundae sunday sundog sundry sunhat sunken sunlit sunned sunray sunset suntan sunups sunway superb supers supine supped supper supple supply surely surest surety surfed surfer surged surger surges surtax survey sutler suture svelte swabby swamis swamps swampy swanks swanky swards swardy swarms swashy swathe swaths swayed swayer swears sweats sweaty sweeps sweets swells swerve swifts swills swines swings swiped swiper swipes swirls swirly swishy switch swivel swoons swoony swoops swoopy swoosh swords sylphs sylphy sylvae sylvan sylvas sylvin symbol synced syndic synods syntan syntax syphon syrinx syrups syrupy system syzygy tabbed tabled tables tablet taboos tabued tacked tacker tackey tackle tactic tagged taggee tagger tahini tailed tailor taints takers taking talcum talent talked talkee talker talkie taller tallow talmud talons tamale tamely tamers tamest taming tamped tamper tampon tandem tangle tangly tangos tanked tanker tanned tanner tannin tanuki taoism taoist tapers taping tapirs tapped tapper target tariff tarmac tarnal tarots tarpan tarred tarrow tarsal tarsus tartan tartar tarter tartly tasers tasked tasker tassel tasted taster tastes tatoos tatter tattle tattoo taught taunts taupes tauten tauter tautly tavern tawdry tawney taxers taxied taxies taxing taxman taxmen tazzas teabag teabox teacup teamed teamer teapot teared tearer teased teasel teaser teases teated teazed teazel teazes teazle techie techno tedium teeing teemed teemer teensy teepee teeter teethe teflon telcos teller telnet temper temple tempos tempts tenant tended tender tendon tenets tenges tenner tennis tenors tenpin tensed tenser tenses tensor tented tenter tenths tenure tepals tepees tephra terete termed terpen terror terser teslas tested tester testes tetany tether tetrad tetras tetric teuton texels texted texter thalli thanks thatch thawed thefts theirs theism theist themed themes thence theory theres therms theses thesis thesps thetas thicks thieve thighs things thingy thinks thinly thiole thione thirds thirst thirty thongs thorax thorns thorny though thrall thrash thread threat threes thresh thrice thrift thrill thrips thrive throat throbs throes throne throng thrown throws thrums thrush thrust thumbs thumps thunks thusly thwack thwart thymes thymey thymic thymol thymus thyrse tiaras tibiae tibial tibias ticked ticker ticket tickle tickly tictac tictoc tidbit tiddly tidied tidier tidies tidily tiding tieing tiered tierod tigers tigery tights tildes tilers tiling tilled tiller tilted tilter timber timbre timely timers timing tinder tinful tinged tinger tinges tingle tingly tinier tinily tinker tinkle tinkly tinman tinmen tinned tinner tinpot tinsel tinted tinter tipcat tiples tipoff tipped tipper tipple tiptoe tiptop tirade tiring tissue titans titbit titers tithed tither tithes tithly titled titles titman titmen titres titter tizzes toasts toasty tocsin todays toddle toecap toeing toffee toggle toiled toiler toilet tokens tokers toking toledo tolled toller toluol tomato tombed tomboy tomcat tomtit tomtom tondos toners tonged tongue tonics toning tonnes tonsil tooled tooler toonie tooted tooter tooths toothy tootle tootsy topics toplit topped topper topple toprim toques toquet torchy tories toroid torpid torpor torque torrid torsos tortes tossed tosses tossup totals totems toters toting totter toucan touche touchy toughs toughy toupee toured tourer tousle touted touter towage toward towels towers towery towing toxemy toxify toxins toxoid toybox toyboy toying traced tracer traces tracks tracts traded trader trades tragic trails trains traits tramel tramps trampy trance trashy trauma travel trawls treads treats treaty treble trebly tremor trench trends trendy trepan triads triage trials tribal tribes tricep trichy tricks tricky tricot tridem triers trifid trifle trijet trikes trills trimer trimly triode triods trione triped triple triply tripod trivet trivia triyne trocar troika trolls trones troops tropes trophy tropic trough troupe trouts trover trowel truant truces trucks trudge truest trumps trunks trusts trusty truths trying tryout trysts tsetse tubers tubful tubing tubule tucked tucker tuffet tufted tufter tugged tugger tugrik tulips tumble tumors tumour tumult tundra tuners tuneup tunics tuning tunnel tuples turban turbid turbos turbot turfed turgid turgor turkey turned turner turnip turret turrid turtle tushes tusked tusker tussle tutors tuxedo twangs twangy tweaks tweeds tweedy tweets tweeze twelve twenty twerps twerpy twiggy twilit twills twined twiner twines twinge twirls twirly twirps twirpy twists twisty twitch twofer twonie twoway tycoon tylote typhad typhus typify typing typist tyrant tyroma tzetze udders uglier uglies ulcers ulnars ultima ultras umbels umbers umbras umlaut umping umpire unable unaged unarch unarms unawed unaxed unbags unbait unbale unband unbans unbars unbear unbelt unbend unbent unbias unbind unblur unbolt unbone unbook unboot unborn unbred unbung unbury uncage uncape uncaps uncart uncase unchid unclad uncles unclew unclip unclog unclot uncock uncoil uncool uncoop uncord uncork uncowl uncued uncuff uncups uncurb uncurl undams undate undead undear undeep undent undies undims undine undock undoer undoes undone unduly undyed unease uneasy uneven unfair unfelt unfirm unfits unfold unfond unfree unfurl unglue ungual unhand unhewn unholy unhook unhurt unions uniped unipod unique unisex unison united uniter unites unjams unjinx unjoin unjust unkept unkind unknit unknot unlace unlaid unlash unlazy unless unlike unlink unlist unlive unload unlock unmade unmake unmans unmaps unmark unmask unmesh unmixt unmold unmown unmute unnest unnumb unopen unpack unpaid unpair unpegs unpens unpent unpick unpins unplay unplug unpure unread unreal unreel unrest unripe unrobe unroll unroot unruly unsafe unsaid unseal unseat unseen unsent unsexy unship unshod unsign unskew unsnap unsold unsort unsown unstep unstop unstow unsung unsure untags unthaw untidy untied untier unties untill untold untrap untrod untrue untuck untune unturn unused unveil unwary unwell unwept unwill unwind unwire unwise unworn unwrap unyoke unzips uparch upbank upbeat update upends upfill upflow upfold upheld uphill uphold upkeep upland uplift uplink upload uplock upmost uppers upping uppish uppity uprate uprear uprise uproar uproot uprush upsets upshot upside upsize uptake uptalk uptick uptime uptown upturn upward upwell upwind uracil urases urates urbane urchin urease uremia uremic ureter urgent urgers urging urinal urines urnful urning uropod uroxin ursine usable usably usages useful ushers usurps usward uterus utiles utmost utopia utters uvular uvulas vacant vacate vacuum vagary vagina vaguer vagues vainer vainly valent valets valgus valley valour valued valuer values valved valves vamped vandal vanish vanity vapers vaping vapors vapory vapour varied varies varoom vassal vaster vastly vatful vatted vaults vaulty vaunts veared vector veered vegans vegged veggie veiled veiler veined velars velcro vellum velour velvet vended vendor veneer venial venoms venous vented venter venues venule verbal verges verify verily verism verist verity vermes vermin vermis vernal versed verses versus vertex vesper vessel vestal vested vestry vetoed vetoer vetoes vetted vexers vexful vexils vexing viable viably vialed vibrio vicars victim victor videos viewed viewer vigils vigour viking vilely vilest vilify villas villus vincas vining violas violed violet violin vipers virgin virify virile virion viroid virome virtue visage viscid viscus vising vision visits visors vistas visual vitals vitium vivify vixens vizier vocals vodkas vogues voiced voicer voices voided voider volley volume volute vomits voodoo vortex votary voteen voters voting votive vowels vowers vowing voxels voyage voyeur vraics vrooms vulgar vulvae vulval vulvar vulvas wabble wabbly wackos wadded wadder waddle waddly waders wading wafers wafery waffle wafted wafter waftes wagers wagged wagger waggle waggly waging wagons wailed wailer waists waited waiter waived waiver waives wakens wakers wakeup waking waling walked walker walkin walkup walled wallet wallop wallow walnut walrus wamble wander wangle waning wanted wanter wanton wapper warble warbly warded warden warder wardog warier warily warmed warmer warmly warmth warmup warned warner warped warper warred warted wasabi washed washer washes washup wasted waster wastes waters watery wattle wauked wauker wauled waulks wavers wavery waveys wavier wavily waving wawled waxcap waxers waxeye waxier waxily waxing waylay wayout wazzas weaken weaker weakly wealth weaned weapon wearer weasel weaved weaver weaves weazen webbed webcam webers weblog wedded wedged wedges weeded weeder weekly weened weensy weeper weevil weighs weight weiner weirdo welded welder welled wended werman wermen wetted wetter whacko whacks whacky whaled whaler whales whammo whammy wharfs wharve wheals wheats wheaty wheels wheeze wheezy whelks whelky whelms whelps whence wheres whiffs whiffy whilst whimsy whined whiner whines whinge whingy whinny whirls whirly whirrs whisks whisky whisps whited whiten whiter whites whizzy wholes wholly whoops whoosh whorls wicked wicker wicket wicopy widely widens widest widget widows widths wields wieldy wiener wienie wifely wifman wifmen wigeon wigged wiggle wiggly wights wiglet wigwag wigwam wilded wilder wildly wilful wilier wiling willed willow wilted wimble wimped wimple winced wincer winces winded winder windex window windup winery winged winger winges winier wining winked winker winkle winner winnow winter wintry wipers wiping wirers wirier wirily wiring wisdom wisely wisest wished wisher wishes wisped witans witchs witchy wither within witted witter wiving wizard wizens woaded wobble wobbly woeful wolfed wolves womans wombat wombed womens wonder wonted wonton wooded wooden woodsy wooers woofed woofer wooing wooled woolen woolie woolly worded worked worker workup worlds worldy wormed wormer worsen worser worths worthy wounds wovens wowing wracks wraith wrasse wraths wreaks wreath wrecks wrench wrests wretch wriest wright wrings wrists writer writes writhe wrongs wryest wursts wusses xebecs xenias xenons xeroma xrayed xylans xylems xylene xyloid xylols xyloma xylose xylyls xyster xystoi xystos xystum xystus yabber yachts yachty yacked yaffed yagers yahoos yairds yakked yamens yammer yamuns yanked yanker yanqui yapock yapoks yapons yapped yapper yarded yarely yarest yarned yarrow yasmak yauped yauper yaupon yawing yawled yawned yawner yawped yawper yclept yealms yeaned yearly yearns yeasts yeasty yeelin yelled yeller yellow yelmed yelmer yelped yelper yenned yeoman yeomen yerbas yesked yessed yesses yester yeuked yexing yields yipped yippee yippie yirred yirths ynones yodels yodled yodler yodles yogees yogini yogins yogurt yoicks yokels yoking yolked yonder yonker yorker youngs youpon youths yowies yowing yowled yowler yttria yttric yuccas yucked yukked yulans yupons yuppie yutzes zaddik zaffar zaffer zaffir zaffre zaftig zagged zambra zamias zanana zander zanier zanies zanily zanzas zapped zapper zareba zariba zarves zayins zealed zealot zeatin zebeck zebecs zebras zebubs zechin zedonk zenana zenith zephyr zeroed zeroes zested zeugma zibeth zibets zigged zigzag zillah zinced zincic zincks zincky zinged zinger zinnia zipped zipper ziptie zirams zircon zither zizith zizzed zizzes zizzle zlotys zoaeae zoaeas zoaria zodiac zoecia zoetic zoftig zombie zombis zonary zonate zondas zoners zoning zonked zonkey zonula zonule zooeae zooeal zooeas zooids zoomed zoonal zooned zoonym zootic zorils zorses zoster zouave zounds zoysia zydeco zygoid zygoma zygose zygote zygous zymase zymins zymoid zythos zythum"
six_letter = six_letter.split(" ")

custom = "ipod zune hulu eprom inuit cajun noir nixon inxs moab moai borat oscar bafta uber lyft tesla ikea gait shogi texas texan okie dour woot derp arity monad enum soba ramen crud cobol honda qrcode tech emoji umami qanat rolex norad tase tased stan rizz dais droid capo Chad Cuba Fiji Iran Iraq Laos Mali Niue Oman Peru Togo Benin Chile China Egypt Gabon Ghana Haiti India Italy Japan Kenya Libya Malta Nauru Nepal Niger Palau Qatar Samoa Sudan Spain Syria Tonga Yemen pune labia chonk asia duty bros taunt obon xanax shit fuck damn bitch cock yentl nerf lexus chibi kobe doge beta meta jedi meme bots bot alpha wiki norad falsy genx genz yale skank"
custom = custom.split(" ")


end()



function()
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
end()



system.javascript("""

// javascript

global.dlog = function(...args) {
  console.log(...args)
}

global.track_event = function(name, props) {
  window.plausible?.(name, props);
}

global.is_safari = function() {
  return /Apple/.test(navigator.vendor) && /Safari/.test(navigator.userAgent)
}

global.daily_path = function() {
  function pad(num) {
    const str = num.toString();
    return str.length === 1 ? `0${str}` : str;
  }
  
  const d = new Date();
  const year = d.getFullYear();
  const month = d.getMonth() + 1;
  const day = d.getDate();
  return `${year}/${pad(month)}/${pad(day)}`;
} 

global.read_params = function() {
  const params = new URLSearchParams(window.location.search);
  const result = {};
  for (const [key, value] of params) {
    result[key] = value;
  }
  return result;
}

global.add_html = function(html) {
  const template = document.createElement('template');
  template.innerHTML = html.trim();
  document.body.appendChild(template.content.firstChild);
  return template.content.firstChild;
}

global.go_to_url = function(url) {
  window.open(url)
}

global.click_link = function(link) {
  document.querySelector("#"+link).click();
}

global.copy_summary = function(board, summary) {
  const emojiboard = board.map(row => {
    return row.map(cell => cell.selected ? "🟥" : "⬜️").join("")
  }).join("\\n");
  
  const text = [
    `${summary.words} words, ${summary.points} points, ${summary.filled}% filled`,
    summary.daily,
    `Verdict: ${summary.heading}`,
    emojiboard
    ].join("\\n");
    
  if (navigator.share) {
    navigator.share({
      title: 'Let The Letter Drop',
      url: 'https://ltld.fun',
      text: text
    })
    .then(() => {
      global.track_event("Share", { via: "WebShareApi"})
    })
    .catch(console.error);
    return true;
  } else {
    global.add_html(`<textarea id="copytext">${text}</textarea>`)
    const el = document.querySelector("#copytext");
    el.select();
    document.execCommand("copy");
    el.remove();    
    global.track_event("Share", { via: "html"})
  }  
}

global.create_page_elements = function(urls) {
  global.add_html(`<a id="about" href="${urls.about}">About</a>`);
  global.add_html(`<a id="feedback" href="${urls.feedback}">Feedback</a>`);
}




""")



function()
Letter = class 
  constructor = function(char, size, x, y)
    this.char = char
    this.size = size
    this.selected = false
    this.target = null
    this.x = x
    this.y = y
    this.tick = 0
    this.enabled = true
  end
  
  on = function()
    selected = true  
  end
  
  done = function()
    target == -1 or at_target()
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
      
      if at_target() then
        target.char = char
        board.score_cell(target)
      end
    end
  end
  
  draw = function()
    local colors = object
      bg = theme.cell_bg
      text = theme.cell_text
      border = theme.cell_border
    end

    if selected then
      colors.bg = green
      colors.text = white
    end
    
    if not enabled then
      colors.bg = theme.cell_bg_disabled
      colors.text = theme.cell_text_disabled
    end
    
    screen.drawRect(x, y, size, size, colors.border)
    screen.fillRect(x, y, size-1, size-1, colors.bg)
    screen.drawText(char, x, y-font_cell_offset, font_board_size, colors.text)
  end
  
end

end()



function()
letter_freq = object
  E = 0.111607
  A = 0.084966
  R = 0.075809
  I = 0.075448
  O = 0.071635
  T = 0.069509
  N = 0.066544
  S = 0.057351
  L = 0.054893
  C = 0.045388
  U = 0.036308
  D = 0.033844
  P = 0.031671
  M = 0.030129
  H = 0.030034
  G = 0.024705
  B = 0.02072
  F = 0.018121
  Y = 0.017779
  W = 0.012899
  K = 0.011016
  V = 0.010074
  X = 0.002902
  Z = 0.002722
  J = 0.001965
  Q = 0.001965
end

two_char_morphemes = ("ab ad bi de en ex in " +
"ob re se un " +
"al ar er ic " +
"st ty ve ze ly or ry th").split(" ")

three_char_morphemes = ("con non out per pre pro " +
"ary ate ent ial " +
"ism ist ity ive ize ory ous ure ture " +
"act cap leg min mod sta " +
"son sect pos ple org not nat ana bio dec dia " +
"eco epi geo gon oxy odo oid").split(" ")

morphemes = two_char_morphemes

shuffle = function(coll)
  new_coll = []
  while (coll.length)
    idx = random.nextInt(coll.length)
    new_coll.push(coll.removeAt(idx))
  end
  new_coll
end

Bag = class
  
  constructor = function(size)
    this.size = size
    this.bag = []
    this.fill()
  end
  
  fill = function()
    bag = []
  end

  empty = function()
    bag.length == 0
  end
  
  next = function(history = [], offset=0)
    local drawn = ""
    
    if _debug then
      drawn = bag.removeAt(offset)
    else
      drawn = bag.removeAt(random.nextInt(bag.length))
    end
    
    if drawn then 
      if history.contains(drawn) and not empty() then
        bag.insert(drawn)
        return this.next(history, offset+1)
      end
      drawn.split("") 
    end
  end
end

Letterbag = class extends Bag
  id = "lb"
  constructor = function(size)
    super(size)
  end
  
  fill = function()
    local bag = []
  
    for letter in letter_freq
      freq = letter_freq[letter]
      count = max(1, round(size*freq))
      for i = 1 to count 
        bag.push(letter) 
      end
    end
  
    this.bag = shuffle(bag)
  end
end

Specialbag = class extends Bag
  id = "sp"
  constructor = function(size)
    super(size)
  end
  
  fill = function()
    local bag = []
    local scount = 0
    for i = 1 to size
      scount += 1
      bag.push(specials_list[random.nextInt(specials_list.length)])
    end
    
    this.bag = shuffle(bag)
  end
end

Morphemebag = class extends Bag
  id = "mo"
  constructor = function(size)
    super(size)
  end
  
  fill = function()
    local bag = []
    for i = 1 to size*morphemes_modifier
      bag.push(morphemes[random.nextInt(morphemes.length)].toUpperCase())
    end
    this.bag = shuffle(bag)
  end
end

DailyLetterbag = class extends Bag
  id = "dailylb"
  constructor = function(raw_daily, _debug=false)
    super()
    this._debug = _debug
    this.bag = this.parse_raw(raw_daily)
  end
  
  parse_raw = function(raw_daily)
    local groups = raw_daily.bag.split(" ")
    local singles = groups[0]
    local tmp = [] 
    
    dw = raw_daily.words.join("").split("")
    tmp = tmp.concat(dw)
    tmp = tmp.concat(singles.split(""))
  
    if _debug then
      tmp
    else
      shuffle(tmp)
    end
  end  
end

DailyMorphemebag = class extends Bag
  id = "dailymo"
  constructor = function(raw_daily, _debug=false)
    super()
    this._debug = _debug
    this.bag = this.parse_raw(raw_daily)
  end
  
  parse_raw = function(raw_daily)
    local tmp = [] 
    morphemes = raw_daily.bag.split(" ")[1]
    
    for i=0 to morphemes.length-1 by 2
      pair = morphemes[i] + morphemes[i+1]
      tmp.push(pair)
    end
  
    if _debug then
      this.bag = tmp
    else
      this.bag = shuffle(tmp)
    end
  end    
end







end()



function()
init = function()
  DEBUGGER = true
  create_page_elements(urls)

  loader = asset_manager.loadFont(font_board)
  settings = read_settings()
  
  // Settings
  cols = 5
  rows = 7
  cell_size = 20
  max_player_pieces = 5
  num_player_specials = 1
  num_player_morphemes = 1
  // max_specials = 2
  special_freq_letter = "A"
  special_freq_modifier = 2
  morphemes_modifier = 0.5
  mode = settings.mode
  
  // Set up playing area
  board_y = 78
  dict = null
  board = null
  tray = null
  curr = null
  letter_bag = null
  daily_words = null
  players = null
  
  // Mobile and mouse controls
  control_pause = new PauseControl(-11, -(screen.height/2)+60, messages.controls_help)
  control_settings = new PauseControl(11, -(screen.height/2)+60, "Set")
  control_move_left = new MoveControl(-screen.width/2+50, -(screen.height/2)+45, true)
  control_move_right = new MoveControl(-screen.width/2+60, -(screen.height/2)+45, false)
  control_rotate = new RotateControl(screen.width/2-70, -(screen.height/2)+30, gray)
  control_select = new SelectControl(screen.width/2-35, -(screen.height/2)+50, red)
  about_link = new AboutLink("About", screen.width/2-18, screen.height/2-8, 6, white)

  // Modals
  modal = null
  
  // Set up players
  curr_player = 0

  // Game state
  ready = false
  flash_words = []
  selected_piece = 0 
  // specials_used = 0
  game_over = false

  reset_game()
  
  if not settings.onboarded then
    settings.onboarded = true
    save_settings()
    modal = new OnboardingModal()
  end
end

reset_game = function(selected_mode)
  if selected_mode then mode = selected_mode end
  dict = new Dictionary()
  board = new Board(rows, cols, cell_size) 
  letter_bag = new Letterbag(cols*rows)
  morpheme_bag = new Morphemebag(cols*rows)
  special_bag = new Specialbag(cols*rows)
  select_modal = new SelectModal()
  tray = new Tray(0, -80, cell_size)
  curr = new Current(0, 125)
  ready = false
  daily_words = []
  flash_words = []
  players = []
  game_over = false
  
  modal = null
  
  if mode == modes.daily then
    loader = asset_manager.loadJSON(daily_path(), function(daily)
      daily_words = daily.words
      dict.add_words(daily.words)
      
      // daily.bag = "PADEPPAAPQ RYLYRERE"
      // daily.words = []
      letter_bag = new DailyLetterbag(daily, false)
      morpheme_bag = new DailyMorphemebag(daily, false)
      init_players()
      ready = true
    end)  
  else
    init_players()
    ready = true
  end  
  
  next_round()
end


init_players = function()
  players = [new Player()]
end

update = function()
  theme = themes[settings.theme]
  
  if not ready then return end
  
  if loader.ready then
    set_font_offsets()
  end
  
  if game_over then 
    if not modal then 
      modal = new SummaryScreen()
      track_event(events.finished)
    end
  end
  
  if modal then
    modal.update()
    return
  else 
    if control_pause.pressed() then
      modal = new SelectModal()
      track_event(events.help_pushed)
    end
    if control_settings.pressed() then
      modal = new SettingsModal()
      track_event(events.settings_pushed)
    end    
  end
  
  about_link.update()
  update_flash_words()

  // Selecting a piece to drop
  if curr.is_pending() then
    if controls.left() then
      piece_move_left()
      
    elsif controls.right() then
      piece_move_right()

    elsif controls.select() then
      curr.set_pieces(current_player().select(selected_piece))
    end
    
  else
    
    if not curr.dropping then
      
      // Moving into position to drop
      if controls.left() then
        curr.move_left()
        
      elsif controls.right() then
        curr.move_right()
    
      elsif controls.up() then
        curr.rotate_ccw()

      elsif controls.down() then
        curr.rotate()
        
      elsif controls.select() then
        curr.drop()
      end

    end
    
    curr.update()

    if curr.done then
      board.update()
      
      debug("TOTAL WORDS: " + board.words_used())
      debug("PLAYER WORDS: " + current_player().words())
      
      if board.filled() or current_player().cant_play() then
        game_over = true
      else
        next_round()  
      end
    end
    
  end
  
end

clear_modal = function()
  modal = null
end

draw = function()
  screen.clear(theme.game_bg)
  screen.setFont(font_board)

  if ready and screen.isFontReady(font_board) then  
    draw_copyright()
    
    board.draw(board_y)
    
    control_pause.draw()
    control_settings.draw()
    control_move_right.draw()
    control_rotate.draw()
    control_select.draw()
    control_move_left.draw()
    
    // Letter drawing
    curr.draw()
    
    // Tray with pieces
    tray.draw(current_player().pieces)
    
    if_daily(draw_daily_words)
    
    draw_played_words()

    // Flash words
    flash_words.forEach(function(fw, index) 
      fw.draw(index) 
    end)

    // Score
    draw_score()

    if modal then
      modal.draw()
    end
    
    draw_header()

  end
end

set_font_offsets = function()
  if is_safari() then
    font_cell_offset = 0
    font_game_over_offset = 3
    font_game_over_button_text_offset = 0
  end
end


read_settings = function()
  prefs = storage.get('settings')
  if not prefs then prefs = object end end
  
  params = read_params()
   
  for p in params
    prefs[p] = params[p]  
  end
  
  
  for d in defaults
    exist = prefs[d]
    if not exist then prefs[d] = defaults[d] end
  end
  
  prefs
end

controls = object
  left = function() keyboard.press.A or keyboard.press.LEFT or control_move_left.pressed() end
  right = function() keyboard.press.D or keyboard.press.RIGHT or control_move_right.pressed() end
  up = function() keyboard.press.W or keyboard.press.UP end
  down = function() keyboard.press.S or keyboard.press.DOWN or control_rotate.pressed() end
  select = function() keyboard.press.SPACE or keyboard.press.ENTER or control_select.pressed() end
end

if_daily = function(fn)
  if mode == modes.daily then fn() end
end


current_player = function()
  players[curr_player]  
end

next_round = function()
  board.reset_score()
  curr = new Current(0, 130)
end


update_flash_words = function()
  local x = 0
  for fw in flash_words
    if fw.done then 
      flash_words.removeElement(fw)
    else
      after x*1.5 seconds do
        fw.update() 
      end
      x += 1
    end
  end
end

draw_score = function()
  local y_offset = 24
  local x_offset = 18
  screen.drawText(messages.score_words, -screen.width/2+x_offset, screen.height/2-y_offset, font_score_text_size, theme.score_text)
  screen.drawText(current_player().word_count(), -screen.width/2+x_offset, screen.height/2-y_offset-14, font_score_size, theme.score_text)
  
  screen.drawText(messages.score_score, screen.width/2-x_offset, screen.height/2-y_offset, font_score_text_size, theme.score_text, white)
  screen.drawText(current_player().score(), screen.width/2-x_offset, screen.height/2-y_offset-14, font_score_size, theme.score_text)
end

draw_played_words = function(color = theme.score_text)
  local x = screen.width/2-24
  local i = 1
  local words = current_player().words()
  local sp = 14
  if words.length > 10 then sp = 11 end
  local y_offset = 8*(words.length+sp)/2
  for w in words
    screen.drawText(w, x, y+y_offset-(i*sp), font_score_text_size, color)
    i+=1
  end
end

draw_daily_words = function()
  local results = []
  
  for w in daily_words
    local color = med_gray
    if current_player().results[w] then
      color = red
    end
    results.push(color)
  end
    
  local x = -screen.width/2+24
  local y = 40
  screen.drawText(messages.todays, x, y+12, font_score_text_size, theme.score_text)
  screen.drawText(messages.words, x, y, font_score_text_size, theme.score_text)
  
  screen.drawText(daily_words[0], x, y-14, font_score_text_size, results[0])
  screen.drawText(daily_words[1], x, y-28, font_score_text_size, results[1])
  screen.drawText(daily_words[2], x, y-42, font_score_text_size, results[2])  
end

draw_mode = function()
  local text = if mode == modes.daily then messages.daily else messages.freeplay end
  screen.drawText(text, 0, screen.height/2-26, 7, white)
end

draw_header = function()
  screen.fillRect(0, screen.height/2-2, screen.width, 29, "rgba(0,0,0,.5)")  
  screen.fillRect(0, screen.height/2, screen.width, 29, red)
  screen.drawText("Let The Letter Drop", 0, screen.height/2-8, 9, white)
  about_link.draw()
end

draw_copyright = function()
  local w = screen.textWidth(messages.copyright, 5)
  screen.drawText(messages.copyright, screen.width/2-w/2-2, -screen.height/2+4, 5, theme.copyright)  
end






end()



function()
messages = object
  daily = "DAILY"
  freeplay = "FREEPLAY"
  score_words = "WORDS"
  score_score = "SCORE"
  game_over = "GAME OVER"
  play_again = "PLAY AGAIN?"
  share = "SHARE"
  todays = "TODAY'S"
  words = "WORDS"
  controls_help = "HELP"
  copyright = "©2023 Todd Lemoine"
end

end()



function()
Modal = class
  constructor = function()
    this.x = 0
    this.y = 0
  end
  draw = function()
    local height = screen.height*.85
    screen.fillRect(x, y, screen.width, screen.height, "rgba(0,0,0,.7)")
    screen.fillRoundRect(x, y-2, screen.width*.8, height, 8, black)
    screen.fillRoundRect(x, y, screen.width*.8, height, 8, theme.modal_bg)
  end
  
end


MiniControls = class
  constructor = function(y)
    this.y = y
    local controls = object
      move_left = control_move_left.clone()
      move_right = control_move_right.clone()
      rotate = control_rotate.clone()
      select = control_select.clone()
    end
    
     for c in controls 
        controls[c].y = controls[c].y+y
     end
    
    this.controls = controls
  end

  draw_callout = function(text, x, y)
    screen.drawLine(x, y, x, y-10, theme.modal_text)
    screen.drawText(text, x, y-20, 7, theme.modal_text)
  end
  
  draw = function()   
    screen.setScale(.65, .65)
    for c in controls controls[c].draw() end
    screen.setScale(1, 1)
    
    draw_callout("Move", -29, controls.move_left.y-16)
    draw_callout("Rotate", 19, controls.rotate.y)
    draw_callout("Use/Drop", 43, controls.select.y-7)
  end
  
end

    

OnboardingModal = class extends Modal
 constructor = function()
    super()
    this.mini_controls = new MiniControls(100)

    this.buttons = object
      ok = new Button("Ok", 100, 0, 0)
    end
  end

  update = function()
    if buttons.ok.pressed() then 
      clear_modal()
    end
  end
  
  draw = function()
    super()
    local height = screen.height*0.85

    screen.drawText("How to Play", 0, (height/2)-24, 18, blue)
    local lines = [
      "Select letters from your tray"
      "to drop on the board. Make words",
      "in any direction. Score points",
      " for 4, 5, & 6-letter words."
    ].forEach(function(line, index)
      screen.drawText(line, 0, (height/2)-48-(index*12), 7.5, theme.modal_text)
    end)
    
    lines = ["Every day, everyone gets 3 words "
    "for the day and the same letters",
    "to use. Try to make all three!"].forEach(function(line, index)
      screen.drawText(line, 0, 46-(index*12), 7.5, red)
    end)

    // Controls
    screen.drawText("Controls", 0, 0, 10, blue)
    mini_controls.draw()
    
    local lines = [
      "Desktop folks: Use arrow keys",
      "to move and rotate, Enter"
      "or Space to select & drop.",
    ].forEach(function(line, index)
      screen.drawText(line, 0, -85-(index*12), 7.5, theme.modal_text)
    end)
    
    
    local count = 0
    for b in buttons
      btn = buttons[b]
      btn.y = -height/2+20+count*10
      btn.draw()
      count+=1
    end

  end
end  



SelectModal = class extends Modal
  constructor = function()
    super()
    this.controls = new MiniControls()
    this.controls = object
      move_left = control_move_left.clone()
      move_right = control_move_right.clone()
      rotate = control_rotate.clone()
      select = control_select.clone()
    end
    
    local buttons = object
      restart = new Button("Restart", 100, 0, 0)
      mode = new Button("Daily Mode", 100, 0, 0)
      back = new Button("Back to Game", 100, 0, 0)
    end

    if mode == modes.daily then
      buttons.mode.text = "Freeplay Mode"
    end
    
    this.buttons = buttons
    this.position_controls()
  end
  
  position_controls = function()
    for c in controls 
      controls[c].y = controls[c].y+215
    end
  end
  
  draw_callout = function(text, x, y)
    screen.drawLine(x, y, x, y-10, black)
    screen.drawText(text, x, y-20, 7, black)
  end
  
  update = function() 
    if buttons.back.pressed() then 
      clear_modal()
    end
    
    if buttons.restart.pressed() then 
      track_event(events.restart, object mode = mode end)
      reset_game()
    end
    
    if buttons.mode.pressed() then 
      if mode == modes.daily then
        track_event(events.switch_mode, object to = modes.free end)
        reset_game(modes.free)
      else
        track_event(events.switch_mode, object to = modes.daily end)
        reset_game(modes.daily)
      end
    end
  end  
  
  draw = function()
    super()
    local height = screen.height*0.85
    screen.drawText("Help", 0, (height/2)-24, 18, blue)
    local lines = [
      "Drop letters to make words",
      "in any direction. Score points "
      "for 4, 5, & 6-letter words.",
    ].forEach(function(line, index)
      screen.drawText(line, 0, (height/2)-48-(index*12), 7.5, black)
    end)

    // Controls
    screen.setScale(.65, .65)
    for c in controls 
      controls[c].draw() 
    end
    screen.setScale(1, 1)
    
    local callout_y = 28
    draw_callout("Move", -29, callout_y)
    draw_callout("Rotate", 19, callout_y)
    draw_callout("Use/Drop", 43, callout_y+13)
    
    local lines = [
      "Desktop: Use arrow keys",
      "to move and rotate, Enter"
      "or Space to select & drop.",
    ].forEach(function(line, index)
      screen.drawText(line, 0, -15-(index*12), 7.5, black)
    end)
    
    
    local count = 0
    for b in buttons
      btn = buttons[b]
      btn.y = -65-(count*30)
      btn.draw()
      count+=1
    end
  end
end

SettingsModal = class extends Modal
  constructor = function()
    super()
    this.buttons = object
      theme = new Toggle(0,80, ["Light", "Dark"])
      mode = new Toggle(0,20, ["Daily", "Freeplay"])
      feedback = new Button("Give Feedback", 100, 0, -64)
      back = new Button("Back to Game", 100, 0, -130)
    end
  end
  
  update = function()
    if settings.theme == "light" then
      buttons.theme.value = "0"
    else
      buttons.theme.value = "1"
    end
    
    buttons.mode.value = settings.mode
    
    if buttons.theme.pressed() then
      toggle_settings_theme()
      track_event(events.toggle_theme, object to = settings.theme end)      
    end

    if buttons.mode.pressed() then
      toggle_settings_mode()
      track_event(events.toggle_default, object to = settings.mode end)
    end
    
    if buttons.feedback.pressed() then
      go_to_url(urls.feedback)
    end
    
    if buttons.back.pressed() then
      clear_modal()
    end    
  end
  
  draw = function()
    super()
    local height = screen.height*0.85
    local half_h = height/2
    screen.drawText("Settings", 0, half_h-24, 18, blue)
    screen.drawText("Theme", 0, half_h-48, 7.5, theme.modal_text)    
    buttons.theme.draw(half_h-70)

    screen.drawText("Default Mode", 0, half_h-108, 7.5, theme.modal_text)    
    buttons.mode.draw(half_h-130)
    
    screen.drawText("Feedback", 0, half_h-168, 7.5, theme.modal_text)    
    local lines = [
      "Suggest a word, report a ",
      "bug, or contact us."
    ].forEach(function(line, index)
      screen.drawText(line, 0, half_h-182-(index*12), 7.5, theme.modal_text)
    end)
    
    buttons.feedback.draw()
    buttons.back.draw()
  end
end

  

end()



function()
Player = class

  constructor = function()
    this.pieces = []
    this.results = object end
    this.daily = []
    this.fill()
    this.history = []
  end
  
  last_played = function(count)
    local _h = []
    local result = object
      specials = []
      morphemes = []
      pieces = []
    end
    
    local x = history.length-1
    
    local all_filled = function(result)
      result.specials.length == count
        and result.morphemes.length == count
        and result.pieces.length == count
    end
    
    while x>-1 and all_filled(result)
      local curr = history[x]
      
      if specials_list.includes(curr) then
        result.specials.push(p)
      elsif p.length > 1 then
        result.morphemes.push(p)
      else
        result.pieces.push(p)
      end
      x -= 1
    end
    
    result
  end
  
  cant_play = function()
    pieces.length == 0 or all(pieces, function(p)
      specials_list.contains(p.join(""))
    end)
  end
  
  
  summary_heading = function()
    _words = words()
    
    //1 points for each word
    //3 points for each daily
    // <5 points = low
    // 5-12 = med
    // 12+ = high    
    local points = _words.length

    if mode == modes.daily then
      for dw in daily_words
        if _words.contains(dw) then 
          points += 3
        end
      end
    end
    
    local coll = global.summary.low
    
    if points > 12 then
      coll = global.summary.high
    elsif points > 5 and points < 13 then
      coll = global.summary.med
    end
    coll[random.nextInt(coll.length)]
  end
  
  summary_desc = function()
    if letter_bag.empty() and morpheme_bag.empty() then
      return "You ran out of letters!"
    end
    ""
  end
  
  summary_daily = function()
    _words = words()
    local num_daily = 0
      for dw in daily_words
        if _words.contains(dw) then 
          num_daily += 1
        end
      end
    num_daily +" out of "+daily_words.length + " daily words"
  end
  
  summary = function()
    object
      heading = summary_heading()
      filled = round(board.percent_filled()*100)
      words = words().length
      points = score()
      daily = summary_daily()
      desc = summary_desc()
    end
  end
  
  words = function()
    w = []
    for r in results
      if results[r] then w.push(r) end
    end
    w
  end
  
  word_count = function()
    local count = 0
    for x in results 
      if results[x] then count += 1 end
    end
    count
  end
  
  add_results = function(latest)
    for x in latest
      results[x.word] = x
    end
  end
  
  remove_results = function(removals)
    for x in removals
      results[x] = undefined
    end
  end
  
  score = function()
    local words = []
    for x in results
      if results[x] then words.push(x) end
    end
    compute_score_for_words(words)
  end
  
  fill = function() 
    local current = reduce(pieces, function(acc, p)
      if specials_list.includes(p.join("")) then
        acc.specials.push(p)
      elsif p.length > 1 then
        acc.morphemes.push(p)
      else
        acc.pieces.push(p)
      end
      acc  
    end, object 
      specials = []
      morphemes = []
      pieces = []
    end)
    
    local recent = last_played(3)
    
    for i = 1 to max_player_pieces-pieces.length
      if not special_bag.empty() and current.specials.length < num_player_specials then
        local next = special_bag.next(recent.specials)
        if next then current.specials.push(next) end
      elsif not morpheme_bag.empty() and current.morphemes.length < num_player_morphemes then
        local next = morpheme_bag.next(recent.morphemes)
        if next then current.morphemes.push(next) end
      else
        local next = letter_bag.next(recent.pieces)
        if next then current.pieces.push(next) end
      end
    end
    
    pieces = concat(current.pieces, current.morphemes, current.specials)
  end
  
  select = function(at)
    piece = pieces.removeAt(at)
    history.push(piece.join(""))
    fill()
    piece
  end
  
end


end()



function()
find_words_in_row = function(row, col_index)
  local words_found = []
  
  for word_len = 5 to 3
    // Take the longest word found.
    if words_found.length > 0 then
      break
    end
    
    for i = max(0, col_index-word_len-1) to min(col_index+word_len-1, row.length-1)
      if row[i].char == " " then continue end

      result = word_at(row, i, word_len)
      
      
      if dict.is_word(result.word) then
        words_found.push(result)
      end

      result = word_at(reverse(row), i-1, word_len)
      
      if dict.is_word(result.word) then 
        words_found.push(result)
      end
    end
  end

  scoreable_words = []
  
  for w in words_found
    if not board.results[w.word] then
      scoreable_words.push(w)
    end  
  end
  
  scoreable_words
end

find_words_in_col = function(coll, index)
  local words_found = []
  
  for word_len = 6 to 4
    if words_found.length > 0 then
      break
    end
    
    for i = min(index+word_len-1, coll.length-1) to max(0, index-word_len-1)
      if coll[i].char == " " then continue end
      
      result = word_at(coll, i, word_len)
      
      if dict.is_word(result.word) then
        add_if_new(words_found, result) 
      end

      result = word_at(reverse(coll), i-index, word_len)
      
      if dict.is_word(result.word) then 
        add_if_new(words_found, result) 
      end
    end
  end
  
  words_found   
end


word_at = function(coll, start_index, word_len, invert_order=false)

  result = object
    cells = []
    word = ""
    pos = []
  end
  
  letters = slice(coll, start_index, start_index+word_len-1)  
  // debug("letters", pick(letters, "char"))
  
  if letters and has_empty_space(letters) == false then
    chars = []
    pos = []
    cells = []
    
    for l in letters
      chars.push(l.char)
      cells.push(l)
    end
    
    result.cells = cells
    result.word = chars.join("")  
    result.pos = pos
  end
  
  result
end


add_if_new = function(coll, result)
  local exists = false
  for i in coll
    if i.word == result.word then 
      exists = true 
      break
    end
  end
  if not exists then
    coll.push(result)
  end
end


compute_score_for_words = function(words)
  local num_daily = 0
  total = 0

  for word in words
    ws = word.length // 1 point for each letter
    multiplier = 1
    if word.length == 6 then multiplier = 15 end
    if word.length == 5 then multiplier = 10 end
    if word.length == 4 then multiplier = 5 end
    total += ws*multiplier
    
    for dw in daily_words
      if word == dw then num_daily += 1 end
    end
    
  end

  if mode == modes.daily then  
    if num_daily > 0 then
      total += num_daily * 100
    end
  end
  
  total  
end


end()



function()
toggle_settings_theme = function()
  if settings.theme == "light" then
    settings.theme = "dark"
  else
    settings.theme = "light"
  end
  save_settings()  
end

toggle_settings_mode = function()
  if settings.mode == "0" then
    settings.mode = "1"
  else
    settings.mode = "0"
  end
  save_settings()  
end

save_settings = function()
  storage.set('settings', settings)
end

end()



function()
specials = object
  "@" = BombSpecial
  "<" = BumpLeftSpecial
  ">" = BumpRightSpecial
end

specials_list = "@<>".split("")

BumpLeftSpecial = class
  special = true
  enabled = true
  
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
      
      if target.col == 0 then
        target.wiggle()
        after 0.5 seconds do
          target.calm()
        end         
        state = 2
      else
        local target_col = max(target.col, 1)
        bump_target = board.drop_target_for(target_col)
        
        if bump_target == -1 then
          target.wiggle()
          after 0.5 seconds do
            target.calm()
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
  enabled = true  
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
        return
      end
      local letter_target_col = min(target.col+1, cols-1)
    
      if letter_target_col == target.col then
        target.wiggle()
        after 0.5 seconds do
          target.calm()
        end         
        state = 2
      else
        bump_target = board.drop_target_for(letter_target_col+1)
        
        if bump_target == -1 then
          target.wiggle()
          after 0.5 seconds do
            target.calm()
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
        if not target.is_selected() then
          target.targeted = false
        end
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
  enabled = true  
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



end()



function()
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

end()



function()
Tray = class
  
  constructor = function(x, y, size=cell_size)
    this.x = x
    this.y = y
    this.size = size
    this.offset = offset
    this.piece_pos = []
  end
  
  draw_selection = function(start_x, start_y, end_x, end_y)
    screen.setLineWidth(3)
    screen.drawLine(start_x, start_y+i, end_x, end_y+i, red)  
    screen.setLineWidth(1)
  end
  
  draw = function(pieces)
    local total_chars = 0
    local piece_pos = []
    
    for piece in pieces
      total_chars += piece.length
    end

    local half_cell = size/2
    local pieces_width = (total_chars+pieces.length-1)*size
    local x = -pieces_width/2 + (half_cell*pieces.length)/2
    
    // Do the layout
    for piece in pieces
      pos = object
        x1 = x
        x2 = 0
      end

      local char_count = 0

      // ******************
      // Specials
      // ******************
      for char in piece
        if char == "@" then
          new BombSpecial(x, y).draw()
        elsif char == "<" then
          new BumpLeftSpecial(x, y).draw()
        elsif char == ">" then
          new BumpRightSpecial(x, y).draw()
        else
          new Letter(char, size, x, y).draw()
        end
        
        x += size
      end
      
      pos.x2 = x
      piece_pos.push(pos)

      // Draw selection
      if selected_piece == piece_pos.length-1 then
        line_y =  y+size/1.35
        line_x1 = pos.x1-half_cell
        line_x2 = pos.x2-half_cell
        draw_selection(line_x1, line_y, line_x2, line_y)
      end
      
      // Add space between pieces
      x += size/2
    end
  end  
  
end


piece_move_left = function()
  selected_piece = max(selected_piece-1, 0)
end

piece_move_right = function()
  selected_piece = min(selected_piece+1, max_player_pieces-1)
end
end()



function()
Toggle = class
  constructor = function(x, y, labels)
    this.x = x
    this.y = y
    this.h = 25
    this.w = 40
    this.r = 25
    this.labels = labels
    this.value = 0
  end
  hovered = function()
    local half_h = h/2
    local half_w = w/2
    local in_y = touch.y < y+half_h and touch.y > y-half_h
    return in_y and touch.x > x-half_w and touch.x < x+half_w
  end
  
  pressed = function()
    hovered() and touch.release
  end
  
  update = function()
  end
  
  draw = function(y)
    screen.drawRoundRect(x, y, w, h, r, blue)
    
    // Toggle
    local t_h = h-4
    local t_pad = 2
    local t_x = x-w/2+t_h/2+t_pad
    if value == "1" then
      t_x = x+(w/2)-t_h/2-t_pad
    end
    screen.fillRound(t_x,y,t_h, t_h, blue)
    
    // Labels
    local text_w = screen.textWidth(labels[0], 8)
    screen.drawText(labels[0], x-w/2-text_w/2-5, y, 8, theme.modal_text)
    
    local text_w = screen.textWidth(labels[1], 8)
    screen.drawText(labels[1], x+w/2+text_w/2+5, y, 8, theme.modal_text)
  end
end



Button = class
  constructor = function(text, width, x, y)
    this.text = text
    this.radius = radius
    this.width = width
    this.color = blue
    this.x = x
    this.y = y
  end
  
  hovered = function()
    local in_y = touch.y < y+6 and touch.y > y-6
    return in_y and touch.x > x-width/2 and touch.x < x+width/2
  end
  
  pressed = function()
    hovered() and touch.release
  end
  
  draw = function()
    local pressing = hovered() and touch.touching
    local attrs = object
      color = color
      x = x
      y = y
    end
    if pressing then 
      attrs.color = gray 
      attrs.y = y-2
    end
    if not pressing then
      screen.fillRoundRect(attrs.x, attrs.y-2, width, 20, 25, black)      
    end
    screen.fillRoundRect(attrs.x, attrs.y, width, 20, 25, color)
    screen.drawText(text, attrs.x, attrs.y+font_game_over_button_text_offset, font_game_over_button_size, white)    
  end
  
end

Link = class
  constructor = function(text, x, y, font_size, color)
    this.text = text
    this.font_size = font_size
    this.width = screen.textWidth(text, font_size)
    this.x = x
    this.y = y
    this.color = color
  end
  
  hovered = function()
    local in_y = touch.y < y+6 and touch.y > y-6
    return in_y and touch.x > x-width/2 and touch.x < x+width/2
  end
  
  pressed = function()
    hovered() and touch.release
  end
  
  update = function()
      
  end
  
  draw = function()
    screen.drawText(text, x, y, font_size, dark_red)    
  end
  
end

end()



function()
concat = function()
  tmp = []
  for list in arguments
    tmp = tmp.concat(list)
  end
  tmp
end

count = function(coll, fn) 
  local x=0
  for c in coll
    if fn(c) then x+=1 end
  end
  x
end

reduce = function(coll, fn, acc)
  for c in coll
    acc = fn(acc, c)
  end
  acc
end

reverse = function(coll)
  new_coll = []
  for i = coll.length-1 to 0
    new_coll.push(coll[i])
  end
  new_coll
end

map = function(coll, fn)
  new_coll = []
  index = 0
  for x in coll 
    new_coll.push(fn(x, index))
    index += 1
  end
  new_coll
end

slice = function(coll, startIndex, endIndex)
  if endIndex > coll.length-1 or startIndex > coll.length -1 then 
    return undefined 
  end
  c = []
  for i = startIndex to endIndex
    c.push(coll[i])
  end
  c
end

pick = function(coll, attr)
  result = []
  for obj in coll 
    result.push(obj[attr]) 
  end
  result
end

unique = function(coll1, coll2)
  tmp = []
  for c in coll2
    if not coll1.contains(c) then tmp.push(c) end
  end
  tmp
end

any = function(coll, fn)
  for x in coll
    if fn(x) then return true end
  end
  false
end

all = function(coll, fn)
  ok = true
  for x in coll
    if fn(x) == false then
      ok = false
      break
    end
  end
  ok
end

concat_unique = function(coll1, coll2)
  for c in coll2
    if coll1.contains(c) == false then coll1.push(c) end
  end
  coll1
end

has_empty_space = function(coll)
  for l in coll
    if l.char == " " then 
      return true
    end
  end
  false
end

shadow_text = function(text, x, y, size=12, color=black)
  screen.drawText(text, x+0.5, y-0.5, size, black)  
  screen.drawText(text, x, y, size, color)    
end


end()


</script></html>