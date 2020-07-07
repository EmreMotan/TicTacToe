pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- syntax shortcuts - https://github.com/tobiasvl/language-pico8
-- dictionaries (tables) - http://lua-users.org/wiki/tablestutorial
-- lua style guide - http://lua-users.org/wiki/luastyleguide
-- pico-8 lua guide - https://pico-8.fandom.com/wiki/lua

--global variables
currentplayer = flr(rnd(1))
--is_gamewon = false
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

-- states
--[[
init_game
choose_player
select_position
win_screen
]]
global_state = ''

-- choose starting player
--currentplayer = flr(rnd(1)) + 1 -- https://pico-8.fandom.com/wiki/rnd

-- player music, if we got it
--music(0)

function initgame()
  -- reset global variables
  currentplayer = flr(rnd(2)) + 1
  --is_gamewon = false
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

  global_state = 'select_position'

  if (is_debugmode) then debugmsg = 'initgame()' end
end

function nextplayer()
  --if currentplayer == -1 then currentplayer = flr(rnd(2)) + 1 -- https://pico-8.fandom.com/wiki/rnd
  if currentplayer == 1 then currentplayer = 2
  else currentplayer = 1
  end

  if (is_debugmode) then debugmsg = 'nextplayer()' end

  global_state = 'select_position'
end

function selectposition()
  print("asdfadf", 15,15,15)
  print ("selectposition", 1, 1, 15)

  x = grid_selector_position

  -- listen for control input
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

      -- check if there's a draw
      tie_result = check_tie_condition()

      if win_result == 1 then
        score[currentplayer] += 1
        global_state = 'win_screen'
      elseif tie_result == 1 then
        global_state = 'tie_screen'
      else global_state = 'next_player'
      end
    end
	end

  if (is_debugmode) then debugmsg = 'selectposition()' end
end

function check_win_condition()
  -- Need to check 8 win conditions - three across, three down, and two diagonal
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

function win_screen()
  r = 0
  r = wait_for_any_input()

  if r == 1 then global_state = 'init_game' end
end

function tie_screen()
  r = 0
  r = wait_for_any_input()

  if r == 1 then global_state = 'init_game' end
end

function title_screen()
  r = 0
  r = wait_for_any_input()

  if r == 1 then global_state = 'init_game' end
end

function wait_for_any_input()
  r = 0

  if btnp(➡️) or btnp(⬅️) or btnp(⬆️) or btnp(⬇️) or btnp(4) or btnp(5)
  then r=1
  end

  return r
end

function drawspr(_spr,_x,_y,_c)
  --palt(0,false)
  if _c !=  nil then
    pal(7,_c)
  end
  spr(_spr,_x,_y)
  pal()
end

function _init()
  global_state = 'init_game'
  --_draw = _draw_main_screen()
  --global_state = 'win_screen'
end

function _update()
  if global_state == 'init_game' then initgame()
  elseif global_state == 'next_player' then nextplayer()
  elseif global_state == 'select_position' then selectposition()
  elseif global_state == 'win_screen' then win_screen()
  elseif global_state == 'tie_screen' then tie_screen()
  else debugmsg = 'invalid global state!!!'
  end
end

--function _draw()
--end

--function _draw_main_screen()
function _draw()
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
  spr(002,x,y)

  -- draw score
  print('Score: '.. score[1] .. ' vs. ' .. score[2], 1, 110 ,12)
  --print('grid val:'..grid[grid_selector_position], 64, 110, 12)

  --print('grid pos:'..grid_selector_position, 1, 110 ,12)
  --print('grid val:'..grid[grid_selector_position], 64, 110, 12)
  --grid_selector_position
  --[[
  --draw the lives
  for i=1,lives do
    spr(004,90+i*8,4)
  end
  ]]

  --debug
  --print("padx: "..padx,1,1,15)

  --rectfill(padx,pady,padx+padw,pady+padh,15)
  --circfill(ballx,bally,ballsize,15)

  -- If win state, display message
  if global_state == 'win_screen' then
    print('player ' .. currentplayer ..' wins!', 1, 1, 15)
    print('press any button for next round!', 1, 9, 15)
  elseif global_state == 'tie_screen' then
    print('it\'s  a tie!', 1, 1, 15)
    print('press any button for next round!', 1, 9, 15)
  else
    --print("current player: "..currentplayer, 1, 1, 12)
    print("current player: ", 1, 2, 12)
    spr(currentplayer-1,60,1)
  end

  -- write debug message
  if (is_debugmode) then print(debugmsg, 1, 120, 12) end -- maybe make this flash?
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
