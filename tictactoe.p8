pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

--[[

Notes:

]]

-------------------------------------------------------------------------------
-- Global Variables
-------------------------------------------------------------------------------
number_players = 1
cpu_difficulty = 3
currentplayer = flr(rnd(1))
gamewinner = -1 -- set to -1 when there is not yet a winner.
grid = {[0] = 0,
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 0,
        [5] = 0,
        [6] = 0,
        [7] = 0,
        [8] = 0,
       }
win_pos = {}
grid_selector_position = 0
debugmsg = ''
is_debugmode = true

-- Scores for players 1 and 2
score = {[1] = 0,
         [2] = 0,
        }

-- play music, if we got it
-- music(0)

timer_count = 0

function _init()
  state_init_match, state_init_game, state_next_player, state_select_position, state_win_screen, state_tie_screen, state_title_screen = 1, 2, 3, 4, 5, 6, 7

  draw_funcs = {[state_init_game]=draw_nothing,
                [state_init_match]=draw_main_screen,
                [state_next_player]=draw_main_screen,
                [state_select_position]=draw_main_screen,
                [state_win_screen]=draw_win_screen,
                [state_tie_screen]=draw_main_screen,
                [state_title_screen]=draw_title_screen
              }
            
  update_funcs = {[state_init_game]=update_init_game,
                [state_init_match]=update_init_match,
                [state_next_player]=update_next_player,
                [state_select_position]=update_select_position,
                [state_win_screen]=update_win_screen,
                [state_tie_screen]=update_tie_screen,
                [state_title_screen]=update_title_screen
              }
  --_draw = _draw_main_screen()
  global_state = state_init_game
end

function _update()
  update_funcs[global_state]()

  timer_count += 1
end

function _draw()
  draw_funcs[global_state]()
end

function update_init_game()
  global_state = state_title_screen

  debugmsg = 'update_init_game()'
end

function update_init_match()
  ------------------------------------------------------------------
  -- Reset Global Variables
  ------------------------------------------------------------------
  currentplayer = flr(rnd(2)) + 1
  gamewinner = -1
  grid = {[0] = 0,
          [1] = 0,
          [2] = 0,
          [3] = 0,
          [4] = 0,
          [5] = 0,
          [6] = 0,
          [7] = 0,
          [8] = 0,
         }
  win_pos = {}
  grid_selector_position = 0

  global_state = state_select_position
  --global_state = state_title_screen

  debugmsg = 'update_init_match()'
end

function update_next_player()
  --if currentplayer == -1 then currentplayer = flr(rnd(2)) + 1 -- https://pico-8.fandom.com/wiki/rnd
  if currentplayer == 1 then currentplayer = 2
  else currentplayer = 1
  end
  
  -- Set cursor position to top left
  grid_selector_position = 0

  global_state = state_select_position

  debugmsg = 'update_next_player()'
end

function update_select_position()
  x = grid_selector_position

  -- Process inputs for human players
  if (currentplayer == 1 or number_players == 2) then
    ------------------------------------------------------------------
    -- Listen for control input
    ------------------------------------------------------------------
      -- if 'right' then x+1, if x>2 then x=0
    if btnp(➡️) then
      x=x+1
      if x % 3 == 0 then x=x-3 end
    end

    -- if 'left' then x-1 % 3, if x<0 then x=2
    if btnp(⬅️) then
      x=x-1
      if x % 3 == 2 or x < 0 then x=x+3 end
    end

    -- if 'up' then y+1, if y>2 then y=0
    if btnp(⬆️) then
      x=x-3
      if x<0 then x=x+9 end
    end

    -- if 'down' then y-1 % 3, if y<0 then y=2
    if btnp(⬇️) then
      x=x+3
      if x>8 then x=x-9 end
    end

    grid_selector_position = x

    if btnp(4) or btnp(5) then -- O or X (https://pico-8.fandom.com/wiki/Btn)
      if grid[grid_selector_position] == 0 then
        grid[grid_selector_position] = currentplayer

        -- check if there is three in a row
        win_result = check_win_condition()

        -- check if there's a potential draw
        tie_result = check_tie_condition()

        if win_result == 1 then
          score[currentplayer] += 1
          global_state = state_win_screen
        elseif tie_result == 1 then
          global_state = state_tie_screen
        else global_state = state_next_player
        end
      end
    end
  end

  -- -- Process input for CPU player
  if (number_players == 1 and currentplayer == 2) then
    -- Random AI
    -- Wait a couple seconds?
    -- Visualize moving the cursor? At some set fraction of a second intervals?

    if (cpu_player_wait_fulfilled == nil or cpu_player_wait_fulfilled == true) then
      cpu_player_wait_fulfilled = false
      timer_count = 0
      timer_end = 30
    end
    
    if (cpu_player_wait_fulfilled == false and timer_count >= timer_end) then
      cpu_player_wait_fulfilled = true
      timer_count = 0
    end

    -- Very basic sequential AI
    if cpu_player_wait_fulfilled == true then
      if (cpu_difficulty == 1) then
        x=0
        position_selected = false
        while (x < 9 and position_selected == false) do
          if grid[x] == 0 then
            position_selected = true
            grid[x] = currentplayer

            -- check if there is three in a row
            win_result = check_win_condition()

            -- check if there's a potential draw
            tie_result = check_tie_condition()

            if win_result == 1 then
              score[currentplayer] += 1
              global_state = state_win_screen
            elseif tie_result == 1 then
              global_state = state_tie_screen
            else global_state = state_next_player
            end
          end
          x += 1
        end
      -- Random position AI
      elseif (cpu_difficulty == 2) then
        x=flr(rnd(9)) + 1
        position_selected = false
        while (position_selected == false) do
          if grid[x] == 0 then
            position_selected = true
            grid[x] = currentplayer

            -- check if there is three in a row
            win_result = check_win_condition()

            -- check if there's a potential draw
            tie_result = check_tie_condition()

            if win_result == 1 then
              score[currentplayer] += 1
              global_state = state_win_screen
            elseif tie_result == 1 then
              global_state = state_tie_screen
            else global_state = state_next_player
            end
          end
          x=flr(rnd(9)) + 1
        end
      -- CPU AI that can detect a line that can be fulfilled
      elseif (cpu_difficulty == 3) then
        -- First pass is to try to identify a position which when populated would result in a line
        -- and therefore a win.
        -- If no such position exists then choose position randomly.
        x=0
        position_selected = false
        while (x < 9 and position_selected == false) do
          if grid[x] == 0 then
            grid[x] = currentplayer

            -- check if there is three in a row
            win_result = check_win_condition()

            if win_result == 1 then
              position_selected = true
              score[currentplayer] += 1
              global_state = state_win_screen
            else
              grid[x] = 0
            end
          end
          x += 1
        end

        -- Second pass is to try to identify a position which when populated would result in a line for the player
        -- and therefore a loss for the CPU.
        x=0
        otherplayer = currentplayer - 1
        if otherplayer == 0 then otherplayer = 2 end
        while (x < 9 and position_selected == false) do
          if grid[x] == 0 then
            grid[x] = otherplayer

            -- check if there is three in a row
            win_result = check_win_condition()

            if win_result == 1 then
              position_selected = true
              grid[x] = currentplayer
              win_pos = {} -- Hacky way to ensure win doesn't actually happen
              win_result = 0
              global_state = state_next_player
            else
              grid[x] = 0
              global_state = state_next_player
            end
          end
          x += 1
        end

        -- If no win or lose positions exist, choose randomly.
        x=flr(rnd(9)) + 1
        while (position_selected == false) do
          if grid[x] == 0 then
            position_selected = true
            grid[x] = currentplayer

            -- check if there is three in a row
            win_result = check_win_condition()

            -- check if there's a potential draw
            tie_result = check_tie_condition()

            if win_result == 1 then
              score[currentplayer] += 1
              global_state = state_win_screen
            elseif tie_result == 1 then
              global_state = state_tie_screen
            else global_state = state_next_player
            end
          end
          x=flr(rnd(9)) + 1
        end
      end
    end
  end
  
  debugmsg = 'update_select_position()'
end

function update_win_screen()
  r = 0
  r = wait_for_any_input()

  if r == 1 then global_state = state_init_match end
end

function update_title_screen()
  if is_title_drawn == nil then
    is_title_drawn = false
  end

  if is_title_drawn == false then
    if draw_tic == nil then
      draw_tic = true
      draw_tac = false
      draw_toe  = false
      timer_end = 30
    end
    
    if (draw_tac == false and timer_count >= timer_end) then
      draw_tac = true
      timer_count = 0
      timer_end = 30
    end

    if (draw_toe == false and timer_count >= timer_end) then
      draw_toe = true
      timer_count = 0
      timer_end = 30
      is_title_drawn = true
    end
  end

  if (is_title_drawn == true and timer_count >= timer_end) then
    title_options_drawn = true

    title_options_selection = 1
  end

  if  title_options_drawn == true then
    -- if 'up' then y+1, if y>2 then y=0
    if btnp(⬆️) then
      number_players -= 1
      if number_players < 1 then number_players = 2 end
    end

    -- if 'down' then y-1 % 3, if y<0 then y=2
    if btnp(⬇️) then
      number_players += 1
      if number_players > 2 then number_players = 1 end
    end

    if btnp(4) or btnp(5) then -- O or X (https://pico-8.fandom.com/wiki/Btn)
      global_state = state_init_match
    end
  end
end

function update_tie_screen()
  r = 0
  r = wait_for_any_input()

  if r == 1 then global_state = state_init_match end
end

function drawspr(_spr,_x,_y,_c)
  --palt(0,false)
  if _c !=  nil then
    pal(7,_c)
  end
  spr(_spr,_x,_y)
  pal()
end

function draw_main_screen()
  -- clear the screen
  rectfill(0,0,128,128,3)

  -- draw grid
  line(48, 20, 48, 108, 15)
  line(76, 20, 76, 108, 15)
  line(20, 48, 108, 48, 15)
  line(20, 76, 108, 76, 15)

  -- draw symbols
  for i=0,8 do
    x = 30 + 30* ((i) % 3)
    if i<3 then y_ =0
    elseif i<6 then y_ =1
    elseif i<9 then y_ =2
    end
    y = 30 + 30*y_
    spr_val=0
    if grid[i] == 0 then spr_val=3
    else spr_val=grid[i]-1
    end
    if count(win_pos) > 0 then
      drawn = 0
      for v in all(win_pos) do
        if i == v then 
          drawspr(spr_val,x,y,8) 
          drawn=1
        end
      end
      if drawn == 0 then drawspr(spr_val,x,y) end
      drawn = nil
    else
      drawspr(spr_val,x,y)
    end
  end

  -- draw selection cursor
  x = 30 + 30* ((grid_selector_position) % 3)
  if grid_selector_position<3 then y_ =0
  elseif grid_selector_position<6 then y_ =1
  elseif grid_selector_position<9 then y_ =2
  end
  y = 30 + 30*y_
  drawspr(002,x,y)

  -- print headline text
  draw_main_screen_headline_text()

  -- write debug message
  if (is_debugmode) then print(debugmsg, 1, 120, 12) end -- maybe make this flash?
end

function draw_win_screen()
  draw_main_screen()
end

function draw_nothing()
  i=1
end

function draw_title_screen()
  -- clear the screen
  rectfill(0,0,128,128,3)

  if (draw_tic == true and draw_tac == true and draw_toe == true) then
    print('TIC TAC TOE', 1, 1, 11)
  elseif (draw_tic == true and draw_tac == true and draw_toe == false) then
    print('TIC TAC', 1, 1, 11)
  elseif (draw_tic == true and draw_tac == false and draw_toe == false) then
    print('TIC', 1, 1, 11)
  end
  
  if (title_options_drawn == true) then
    if (title_options_color == nil) then
      title_options_color = 1
      timer_count = 0
      timer_end = 2
    end
    
    if timer_count >= timer_end then
      title_options_color += 1
      -- if title_options_color > 16 then  
      --   title_options_color = 1
      -- end
      timer_count = 0
    end
    
    print('1 Player', 20, 40, title_options_color + 2)
    print('2 Player', 20, 52, title_options_color + 1)

    -- draw selection symbol 
    print('⬆️', 10, 40 + (number_players - 1) * 12, title_options_color)
  end
end

function draw_main_screen_headline_text()
  if global_state == state_win_screen then
    print('player ' .. currentplayer ..' wins!', 1, 1, 15)
    print('press any button for next round!', 1, 9, 15)
  elseif global_state == state_tie_screen then
    print('it\'s  a tie!', 1, 1, 15)
    print('press any button for next round!', 1, 9, 15)
  else
    print("current player: ", 1, 2, 12)
    drawspr(currentplayer-1,60,1)
    if (currentplayer == 1 or number_players == 2) then
      print("("..currentplayer..")", 68, 2, 12)
    elseif (currentplayer == 2) then
      print("(CPU)", 68, 2, 12)
    end
    print('Score: ', 1, 12 , 12)
    print(score[1] .. '-' .. score[2], 26, 12, 7)
  end
end

function check_win_condition()
  -- Need to check 8 win conditions - three across, three down, and two diagonal.
  -- There's probably a more elegant and scalable way to do this, but I couldn't
  -- quickly figure it out.
  result = 0

  -- Horizontal - Top
  if (grid[0] * grid[1] * grid[2]) == 1 then 
    result = 1 
    win_pos = {0,1,2}
  elseif (grid[0] * grid[1] * grid[2]) == 8 then
    result = 1
    win_pos = {0,1,2}

  -- Horizontal - Middle
  elseif (grid[3] * grid[4] * grid[5]) == 1 then
    result = 1
    win_pos = {3,4,5}
  elseif (grid[3] * grid[4] * grid[5]) == 8 then
    result = 1
    win_pos = {3,4,5}

  -- Horizontal - Bottom
  elseif (grid[6] * grid[7] * grid[8]) == 1 then
    result = 1
    win_pos = {6,7,8}
  elseif (grid[6] * grid[7] * grid[8]) == 8 then
    result = 1
    win_pos = {6,7,8}

  -- Vertical - Left
  elseif (grid[0] * grid[3] * grid[6]) == 1 then
    result = 1
    win_pos = {0,3,6}
  elseif (grid[0] * grid[3] * grid[6]) == 8 then
    result = 1
    win_pos = {0,3,6}

  -- Vertical - Middle
  elseif (grid[1] * grid[4] * grid[7]) == 1 then
    result = 1
    win_pos = {1,4,7}
  elseif (grid[1] * grid[4] * grid[7]) == 8 then
    result = 1
    win_pos = {1,4,7}

  -- Vertical - Right
  elseif (grid[2] * grid[5] * grid[8]) == 1 then
    result = 1
    win_pos = {2,5,8}
  elseif (grid[2] * grid[5] * grid[8]) == 8 then
    result = 1
    win_pos = {2,5,8}

  -- Diagonal - Top Left
  elseif (grid[0] * grid[4] * grid[8]) == 1 then
    result = 1
    win_pos = {0,4,8}
  elseif (grid[0] * grid[4] * grid[8]) == 8 then
    result = 1
    win_pos = {0,4,8}

  -- Diagonal - Top Right
  elseif (grid[2] * grid[4] * grid[6]) == 1 then
    result = 1
    win_pos = {2,4,6}
  elseif (grid[2] * grid[4] * grid[6]) == 8 then
    result = 1
    win_pos = {2,4,6}

  else result = 0
  end

  return result
end

function check_tie_condition()
  -- Need to check 8 win conditions - three across, three down, and two diagonal
  result = 0

  if (grid[0]>0 and
      grid[1]>0 and
      grid[2]>0 and
      grid[3]>0 and
      grid[4]>0 and
      grid[5]>0 and
      grid[6]>0 and
      grid[7]>0 and
      grid[8]>0
    ) then result = 1
  else result = 0
  end

  return result
end

function wait_for_any_input()
  r = 0

  if btnp(➡️) or btnp(⬅️) or btnp(⬆️) or btnp(⬇️) or btnp(4) or btnp(5)
  then r=1
  end

  return r
end

__gfx__
00000000000000007777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000070000007000000000ff0ff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000770007000000700000000fffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000007007007000000700077000fffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000070070070000007000770000fffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000077000700000070000000000fff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007000000700000000000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011000200c0531c000273131a000246152461500000000000c053000002460000000246152461527313000000c053000000000000000246150030024615000000c05324615246152461524615000002731300000
__music__
02 00424344
