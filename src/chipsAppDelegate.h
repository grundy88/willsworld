/*
 
 v1.1
 x block slapping (CCLP3 16)
 n rate alert
 n rate button instead
 x disable passwords
 n password to always get fullscore (remove death penalty)
 n password entry on settings screen
 x include CCLP3
 x make CC1 Icehouse that starts on a force floor work (allow side force exit at start)
 x prevent jumping off force at first step
 x die when releasing stationary creatures
 n blocks should keep moving after trap release (even through multiple traps) [no it's a lynx thing]
 x blocks released from trap should be pushable (CCLP3 141)
 x don't flick if thin wall is on my tile
 x put back JLs Set Them Free level
 x don't allow a self clone with immediately neighboring button (CCLP3 101)
 x bounce back from blocked teleport, should push block (CCLP3 50)
 x block teleported into a trap then released should slide off (CCLP3 140)
 n can't walk backward off a force floor even if the force dir is blocked [can in MS so leaving it]
 x multiple consecutive slide overrides (CCLP3 144)
 x don't push block at end of slide even when overriding perpendicular (CCLP3 144)

 v1.0
 x universal for ipad
   x support larger tileset images
   x fix fuzzy tiles
   x menus
   x button positions (one hand left and right)
   x Default-Portrait.png
   n Default-Landscape.png
 x initial hello alert + pulse menu button
 n level pack completion celebration?
 n clone/cloneblock push behavior (see CCLevel.m)
 x sound
   x UI button down/up [clickDown/clickUp]
   x splash (chip or block or monster goes in water) [splash]
   x burn (chip or monster dies in fire) [fire]
   x killed by monster
   x crushed by block
   x explosion (chip or monster or block explodes bomb) [bomb]
   x out of time [waa]
   x time ticks for last few seconds [clickDown]
   x exit [woohoo]
   x "oof" (chip move is blocked) [oof]
   x chip teleport [teleport]
   x button stepped on (by chip or monster or block) [clickUp]
   x pick up chip [coin]
   x pick up key [key]
   x pick up footwear [footwear]
   x thief
   x open gate/socket
   x open a door
   x pop up wall
   x buried tile
 x play all sounds / only onscreen / chip only / none
 x allow to skip level (if 10 attempts in a row, each one lasting at least 10 seconds)
 x track total attempts before level completion
 x show levelset progress on levelset selection page
 x detect new best time and/or high score
 x splash screen
 x icon
 x tile set
 x ad display/retrieval
 - ijacks ad creative
   - 4 screenshots
     - full night and day cycle
     - tons of unlockables and achievements
     - improve your hand-to-iphone coordination
     - almost as fun as actually going outside
   - this ad will self destruct in 
   - install iJacks and never see this ad again (animate in text)
   - done bar
   - tap anywhere to appstore
   - both orientations
 x included level packs
   x lesson levels
      - (1) gather coins to open gate
      - (1) gather keys to open doors (green lasts forever)
      - (2) push blocks, into water to make dirt
      -     step on dirt to make floor
      - (2) avoid monsters
      - (3) various footwear
      - (4) blue button
      - (4) green button
      - (4) things under blocks
      - (5) red button and clone machine
      - (5) brown button
      - (6) blue walls
      - (6) invisible walls
      - (6) extra coins
      - (7) teleports (are directional)
      - (7) quicksand
      - (7) popup walls
      - (8) monsters stopped by dirt and gravel
    n advanced lessons
      - flick
      - ram
      - things hidden under floors
      - monsters erase things under floors
 
 x menu
   x select level
     x list all levels in current pack
     x indicate which have been completed/best score
     x indicate level pack completion %
     x password entry if level not yet accessed
   x select player
   x select level pack
     x list all available packs
     x indicate level pack completion %
     x allow rename
     x download
       x enter url
       x if .dat then download and verify
       n else show web page
   x appearance
   x instructions
   n select skin
     n list all available skins
     n download
       n if .zip then download, unzip, and verify
       n else show web page
 x control scheme select
   x control scheme help
 x autorotate
 x skinnable:
   x tiles image
   x background image
   n button images
   n digits image
   n bevel light/dark/fill colors
   n item badge outline/fill colors
   n info/item text color
   x "Chips Left" text
   n character name
   n died messages
   n sounds
 
 ==========================================================
 
 Features in MS but not here:
 - boosting
 - skate over ice corners
 - cross checking
 - slide delay
 - concussion rule (necessitates a change to CC1 #70: Nightmare)
 
 Features in Lynx but not here:
 - green key and hint blocks monsters
 - balls bounce off each other
 - weird trap behavior - sliding through when inactive, and moving when released
 
 Features in MS and here:
 - flick
 - ram
 
 Glitches in MS but not here:
 - controller and boss glitch
 - teleport skip glitch
 - mouse panel glitch
 - long first second glitch
 - button smash glitch
 - tank top glitch
 - spontaneous monster glitch
 - non-existence glitch (there just will be no chip)
 - frankenstein glitch
 - convergence glitch
 - transparency glitch
 - termination glitch
 - data resetting
 - multiple tank glitch
 
 Level Changes:
 + CCLP2 #14: The Parallel Port - remove ice corner
 - CCLP2 #30: Chase Race - remove two ice corners (required shifting entire middle section left one square)
 - CCLP2 #53: Security Breach - move two moving pink balls down one and start them facing south
 + CCLP2 #57: Quad Boot - turn force floors at the beginning, add thin walls after getting footwear
 - CCLP2 #61: Icy Moat - open up floor to right of down force tile
 - CCLP2 #62: Chips on the Blocks - remove wrong facing force from ice slide
 - CCLP2 #92: Abandoned Mines - reverse force tiles in middle row
 - CCLP2 #124: Paramecia - remove teleport at 25,3 to avoid teleport loop
 
 Unsolvable in Lynx but okay here:
 + CCLP2 #15: Debug File (flick)
 - CCLP2 #24: Sudden Death (clone block stays in place)
 - CCLP2 #27: Frozen Floors (force floor side exit after ice)
 - CCLP2 #44: Fun House Rink (force floor side exit after ice)
 - CCLP2 #55: Dangers of Fire and Beasts (gliders do die on fire)
 - CCLP2 #73: Bumble Boy (you can move right away)
 - CCLP2 #104: Pyramid (non-moving monsters recognized)
 - CCLP2 #111: Monster Factory (gliders do die on fire)
 - CCLP2 #136: Switch Hit (flick)
 
 Lynx unsolvable (exploit MS glitch):
 24 27 30 44 53 55 62 73 92 104 111 119 124 125 136
 
 Lynx unplayable (invalid tile combinations):
 14 15 17 19 21 22 26 28 34 45 47 48 54 57 59 64 68 70 71 72 74 76 78 80 81 82 85 86 87 93 
 98 99 105 106 108 109 112 116 120 127 130 131 132 133 134 137 139 142
 
 Lynx unplayable & unsolvable:
 14 15 57 105
 
 Verified:
   1 
   2 
   3 
   4 
   5 
   6 
   7 
   8 
   9 
  10 
  11 
  12 
  13 
  14 
  15 
  16 
  17 
  18 
  19 
  20 
  21 
  22 
  23 
  24 
  25 
  26 
  27 
  28 
  29 
  30 
  31 
  32 
  33 
  34 
  35 
  36 
  37 
  38 
  39 
  40 
  41 
  42 
  43 
  44 
  45 
  46 
  47 
  48 
  49 
  50 
  51 
  52 
  53 
  54 
  55 
  56 
  57 
  58 a
  59 
  60 
  61 
  62 a
  63 
  64 a
  65 
  66 
  67 
  68 
  69 a
  70 
  71 
  72 
  73 
  74 
  75 
  76 
  77 
  78 
  79 
  80 
  81 
  82 
  83 
  84 
  85 
  86 
  87 
  88 
  89 
  90 
  91 
  92 
  93 
  94 
  95 
  96 
  97 
  98 
  99 
 100 
 101 
 102 
 103 
 104 
 105 
 106 
 107 
 108 
 109 
 110 
 111 
 112 
 113 a
 114 
 115 
 116 
 117 
 118 
 119 
 120 
 121 
 122 a
 123 
 124 
 125 
 126 
 127 
 128 
 129 
 130 
 131 
 132 a
 133 
 134 
 135 
 136 
 137 
 138 a
 139 
 140 
 141 a
 142 
 143 
 144 
 145 
 146 
 147 
 148 
 149 
 

 Levels:
 Codes:
 - A: haven't tried
 - D: don't know how to solve
 - K: know what to do but haven't completed
 - G: gave up before I got to all puzzles
 - C: completed
 - I: invalid - requires boosting or stepping over ice corners
 Difficulties: 1 (easy) - 5 (hard)
 - p = planning - how hard to figure out what to do
 - e = execution - how hard to do it (dexterity, time limit, memorization)
 Characteristics: 0 (no impact) - 5 (heavy impact)
 - l = luck
 - t = trial & error / guessing
 
 JL1
 ---
  #  | code | d | p | e | l | t | c | notes
----------------------------------------------------
 001 |  G   |   |   |   |   |   | 
 002 |  K   | 2 |   |   |   |   | y
 003 |  C   | 2 | 2 | 2 |   |   | y
 004 |  C   | 4 | 4 | 2 |   |   | y | block and key
 005 |  C   | 2 | 2 | 2 |   |   | y
 006 |  C   | 1 |   |   |   |   | n | don't really like - lots of force floors
 007 |  C   | 3 | 2 | 3 |   |   | y
 008 |  G   |   |   |   |   |   | n | frustrating maze of toggles and walkers + block pushing
 009 |  G   |   |   |   |   |   | n | blind sliding
 010 |  C   | 3 |   |   |   |   | y 
 011 |  K   | 3 |   |   |   |   | y | criss crosses of gliders and fireballs
 012 |  C   | 3 |   |   |   |   | y
 013 |  C   | 2 |   |   |   |   | y
 014 |  C   | 3 |   |   |   |   | y
 015 |  D   |   |   |   |   |   | n | more toggles and walkers
 016 |  D   | 4 |   |   |   |   | y | managing direction
 017 |  C   | 3 |   |   |   |   | y
 018 |  K   | 3 |   |   |   |   |   | sliding blocks round and round
 019 |  K   | 2 |   |   |   |   | y | maze of toggles and green doors
 020 |  C   | 3 |   |   |   |   | y | 
 021 |  D   | 4 |   |   |   |   | y | sokoban - move blocks into areas, toggle, repeat
 022 |  G   | 2 |   |   |   |   | y | double maze + toggles
 023 |  K   | 3 |   |   |   |   | y | construct-a-maze - ran out of time
 024 |  D   |   |   |   |   |   | n | maze with teeth and red keys
 025 |  D   |   |   |   |   |   |   | four door
 026 |  D   |   |   |   |   |   |   | blocks on ice
 027 |  K   | 2 |   |   |   |   | y | frustrating at the end - don't know which door to go through
 028 |  D   |   |   |   |   |   |   | over and under
 029 |  C   | 3 | 4 | 2 |   |   | y
 030 |  K   | 2 |   |   |   |   | y | maze of blue walls and doors
 031 |  C   | ? |   |   |   |   | n | busted on iphone
 032 |  K   | 2 |   |   |   |   | y
 033 |  G   |   |   |   |   |   | n | force sliding into death
 034 |  G   |   |   |   |   |   | n | blind sliding
 035 |  D   |   |   |   |   |   |   | scatter brain
 036 |  C   | 3 | 2 | 3 | 0 | 0 | y
 037 |  K   | 3 | 2 | 3 | 0 | 0 | y | push blocks through teleports in small rooms without getting stuck
 038 |  D/G |   | 5 |   |   |   |   | grand fun alley
 039 |  C   | 2 | 2 | 2 | 0 | 0 | y
 040 |  C   | 5 | 5 | 3 | 0 | 0 | y | four-by-four
 041 |  K   | 5 | 4 | 5 | 0 | 0 | maybe - requires dexterity - monster spirals
 042 |  D   |   |   |   |   |   |   | run of the mill
 043 |  G   |   |   |   |   |   | n | force sliding to avoid bombs
 044 |  G   | 4 | 3 | 5 | 0 | 0 | y
 045 |  C   | 2 | 3 | 2 | 0 | 0 | y
 046 |  K   | 4 | 5 | 4 | 0 | 1 | n
 047 |  G   | 4 | 2 | 5 | 0 | 0 | n
 048 |  C   | 4 | 4 | 2 | 0 | 0 | y
 049 |  K   | 5 | 5 | 4 | 0 | 0 | 
 050 |  D   |   |   |   |   |   |   | before the rainstorm
 051 |  G   | 4 | 2 | 5 | 0 | 0 | n | brutal block bouncing puzzle
 052 |  D   |   |   |   |   |   |   | escape from the pupil
 053 |  C   | 4 | 4 | 4 | 0 | 0 | y
 054 |  K   | 4 | 3 | 4 | 0 | 0 | y
 055 |  D   |   |   |   |   |   |   | blockhead 
 056 |  G   |   |   |   |   |   | n | toggles + teeth
 057 |  D   |   |   |   |   |   |   | bulge
 058 |  C   | 5 | 5 | 2 |   |   | y
 059 |  C   | 3 | 2 | 3 | 0 | 0 | y
 060 |  D   |   | 5 |   |   |   |   | can't get the bottom chip
 061 |  C   | 4 | 4 | 1 | 0 | 0 | y
 062 |  D/G |   | 5 |   |   |   | 
 063 |  C   | 3 | 3 | 2 | 0 | 0 | y
 064 |  G   | 4 | 2 | 4 | 0 | 0 | y
 065 |  D   | 5 |   |   |   |   |   | grand prix
 066 |  K   | 4 | 2 | 4 | 0 | 0 | maybe
 067 |  G   |   |   |   |   |   | freezer - have to repeat beginning too much
 068 |  G   |   | 3 | 3 |   |   | 
 069 |  D   |   |   |   |   |   |   | crosshairs
 070 |  D   |   |   |   |   |   |   | magic trick
 071 |  G   | 4 | 3 | 4 |   |   | checkers - maybe
 072 |  D   |   |   |   |   |   |   | to catch a thief
 073 |  G   | 4 | 2 | 4 |   |   | grocery store - maybe
 074 |  C   | 4 | 4 | 2 | 0 | 0 | y
 075 |  C   | 5 | 5 | 3 |   |   | y | the HARDEST level
 076 |  G   |   | 3 | 3 | 0 | 0 | wireframe - maybe - flick
 077 |  G   |   | 2 | 4 | 0 | 0 | hold on - maybe
 078 |  G   |   | 2 | 4 | 0 | 0 | confinement - maybe
 079 |  G   | 3 | 1 | 3 | 0 | 0 | y
 080 |  D   |   |   |   |   |   |   | rotation
 081 |  C   | 3 | 3 | 3 | 0 | 0 | y
 082 |  G   | 4 | 2 | 4 | 0 | 0 | y
 083 |  C   | 4 | 4 | 2 | 0 | 0 | n | good but busted on iphone
 084 |  G   |   |   |   |   |   | force circle - maybe but probably not
 085 |  G   | 4 | 4 | 4 |   |   | beat the heat - maybe
 086 |  C   | 3 | 3 | 2 | 0 | 0 | y
 087 |  G   | 4 | 2 | 4 | 0 | 0 | maybe
 088 |  G   | 3 | 3 | 3 | 0 | 0 | y
 089 |  C   | 3 | 3 | 2 | 0 | 0 | y
 090 |  G   | 3 | 3 | 2 | 0 | 0 | y
 091 |  D   |   |   |   |   |   |   | think tank
 092 |  C   | 3 | 3 | 2 | 0 | 0 | y
 093 |  C   | 5 | 5 | 5 |   |   | y | mudpie - actually this may be the hardest
 094 |  G   | 3 | 3 | 3 | 0 | 0 | y
 095 |  A   |   |   |   |   |   | 
 096 |  G   | 2 | 1 | 2 | 0 | 0 | y | hidden/false wall maze
 097 |  D   |   |   |   |   |   |   | once upon a troubador
 098 |  C   | 5 | 5 | 3 |   |   | y | floating plaza
 099 |  D   |   |   |   |   |   |   | mr mccallahan presents
 100 |  A   |   |   |   |   |   | n | thank you level
 
 Ida3
 ----
  #  | code | d | p | e | l | t | c | notes
 ----------------------------------------------------
 001 |  C   | 1 | 2 | 1 |   |   | y
 002 |  C   | 1 | 2 | 1 |   |   | maybe | ok but seems like a gimmick
 003 |  C   | 2 | 2 | 1 |   |   | y
 004 |  C   | 2 | 2 | 2 |   |   | y
 005 |  C   | 3 | 2 | 3 |   |   | maybe - bumper
 006 |  D/G |   |   |   |   |   | n | give up before getting all walkers to bombs
 007 |  C   | 2 | 2 | 3 |   |   | maybe - difficulties (fix getting stuck in force)
 008 |  C   | 2 | 1 | 3 |   |   | y
 009 |  K   | 2 | 2 | 2 |   |   | maybe | opening blind block push is lame
 010 |  G   | 1 | 1 | 1 |   |   | n | busy work
 011 |  C   | 1 | 1 | 2 |   |   | y
 012 |  K   | 2 | 2 | 1 |   |   | y
 013 |  K   | 2 | 2 | 1 |   |   | y
 014 |  D   |   |   |   |   |   |   | don't know how to get something to bomb
 015 |  C   | 2 | 2 | 1 |   |   | y
 016 |  C   | 2 | 3 | 1 |   |   | y
 017 |  C   | 1 | 1 | 1 |   |   | y
 018 |  C   | 2 | 2 | 1 |   |   | y
 019 |  C   | 1 | 1 | 1 |   |   | y
 020 |  D   |   |   |   |   |   |   | how to slow down outer glider
 021 |  G   |   |   |   | 1 |   | 
 022 |  K/G |   |   |   |   |   | 
 023 |  C   | 2 | 2 | 1 |   |   | y
 024 |  C   | 1 | 1 | 1 |   |   | n | about buttons
 025 |  C   | 1 | 1 | 1 |   |   | n | animal farm
 026 |  K   | 2 | 1 | 2 |   |   | maybe | sokoban with invisible walls
 027 |  K   | 2 | 2 | 1 |   |   | y
 028 |  C   | 2 | 3 | 1 |   |   | y
 029 |  C   | 2 | 3 | 1 |   |   | y
 030 |  C   | 2 | 1 | 2 |   |   | y
 031 |  C   | 2 | 1 | 2 |   |   | y
 032 |  C   | 1 | 1 | 2 |   |   | y
 033 |  C   | 2 | 1 | 2 |   |   | y
 034 |  K   | 3 | 2 | 3 |   |   | maybe | (the force be with you) annoying sliding end
 035 |  A   |   |   |   |   |   | 
 036 |  D   |   |   |   |   |   | n | welcome to sweden
 037 |  C   | 2 | 1 | 2 |   |   | y | (you made the bed) more force sliding
 038 |  C   | 2 | 2 | 1 |   |   | y
 039 |  C   | 3 | 3 | 2 |   |   | y | mini-challenges I
 040 |  C   | 2 | 1 | 2 |   |   | y
 041 |  K   | 2 | 2 | 2 |   |   | n | repetitive toggle switch running
 042 |  D/G | 3 | 2 | 3 |   |   | n | (genvag) annoying random-force+bugs
 043 |  C   | 3 | 3 | 2 |   |   | y
 044 |  C   | 4 | 4 | 4 |   |   | y | mini-challenges II
 045 |  C   | 3 | 3 | 1 |   |   | y
 046 |  C   | 4 | 4 | 4 |   |   | y | mini-challenges III
 047 |  C   | 5 | 5 | 2 |   |   | y | suicide?
 048 |  C   | 1 | 1 | 1 |   |   | n | inside reference to Melinda
 
 Ida
 ---
  #  | code | d | p | e | l | t | c | notes
 ----------------------------------------------------
 001 |  x   |   |   |   |   |   | 
 002 |  x   |   |   |   |   |   |   | Ida3: Do The Trick
 003 |  x   |   |   |   |   |   | 
 004 |  x   |   |   |   |   |   |   | Ida3: Memory II
 005 |  x   |   |   |   |   |   | 
 006 |  x   |   |   |   |   |   |   | Ida3: Wait a Minute...
 007 |  x   |   |   |   |   |   | 
 008 |  x   |   |   |   |   |   | 
 009 |  C   | 1 | 2 | 1 |   |   | y
 010 |  x   |   |   |   |   |   | 
 011 |  C   | 1 | 2 | 1 |   |   | y | simple yet repetitive sokuban
 012 |  D   |   |   |   |   |   |   | tons of locks (i love y)
 013 |  C   | 2 | 2 | 1 |   |   | y
 014 |  x   |   |   |   |   |   |   | Ida3: At the Snail's
 015 |  x   |   |   |   |   |   | 
 016 |  C   | 2 | 1 | 2 |   |   | y
 017 |  C   | 2 | 1 | 2 |   |   | y
 018 |  C   | 2 | 1 | 2 |   |   | maybe | just gather all the chips 
 019 |  C   | 1 | 1 | 1 |   |   | maybe | clone glider into bombs, too easy
 020 |  x   |   |   |   |   |   | 
 021 |  C   | 3 | 3 | 1 |   |   | y
 022 |  D/G |   |   |   |   |   | 
 023 |  G   |   |   |   |   |   | n | another opening blind block push
 024 |  D   |   |   |   |   |   | n | can't get it done in time
 025 |  C   | 1 | 1 | 1 |   |   | n | just follow the green doors
 
 Ida4
 ----
  #  | code | d | p | e | l | t | c | notes
 ----------------------------------------------------
 001 |  C   | 5 | 5 | 2 |   |   | y
 002 |  C   | 4 | 4 | 2 |   |   | y
 003 |  C   | 4 | 2 | 4 |   |   | y
 004 |  C   | 2 | 2 | 2 |   |   | y
 005 |  C   | 4 | 4 | 2 |   |   | y
 006 |  G   | 5 | 2 | 4 |   |   |   | duck
 007 |  C   | 5 | 5 | 2 |   |   | y
 008 |  C   | 3 | 3 | 2 |   |   | y
 009 |  C   | 2 | 2 | 2 |   |   | y
 010 |  C   | 5 | 2 | 5 |   |   | y
 011 |  C   | 1 | 1 | 2 |   |   | y
 012 |  C   | 2 | 2 | 2 |   |   | y
 013 |  C   | 4 | 4 | 3 |   |   | maybe | skate park
 014 |  C   | 5 | 5 | 5 |   |   | y
 015 |  C   | 3 | 2 | 3 |   |   | y
 016 |  C   | 3 | 2 | 2 |   |   | y
 017 |  C   | 3 | 2 | 3 |   |   | y
 018 |  C   | 4 | 2 | 4 |   |   | y
 019 |  C   | 4 | 4 | 3 |   |   | y
 020 |  x   |   |   |   |   |   | n | 

 PeterM2
 -------
  #  | code | d | p | e | l | t | c | notes
 ----------------------------------------------------
 001 |  x   |   |   |   |   |   | n | have to keep doing the same opening as it's easy to die later
 002 |  x   | 4 | 4 | 2 |   |   | y | not lynx compatible
 003 |  G   |   |   |   |   |   | n | maze with bug walls
 004 |  x   | 3 | 2 | 3 |   |   | y
 005 |  x   | 2 | 2 | 2 |   |   | maybe
 006 |  D   | 4 | 4 | 2 |   |   | would like to - can't figure out last puzzle
 007 |  G   |   |   |   |   |   | n | (enter the swarm)
 008 |  x   |   |   |   |   |   | n | see 001
 009 |  x   |   |   |   |   |   | n | mindless repetitive block pushing into bombs
 010 |  G   |   |   |   |   |   | n | lesson 5 with tons of extras
 011 |  x   | 2 | 2 | 2 |   |   | y / maybe
 012 |  I   |   |   |   |   |   | n
 013 |  D   |   |   |   |   |   | n
 014 |  D   |   |   |   |   |   | n | monster madness
 015 |  x   |   |   |   |   |   | n
 016 |  x   | 2 | 2 | 1 |   |   | y
 017 |  G   |   |   |   |   |   | maybe | not lynx compatible (domination)
 018 |  D   |   |   |   |   |   | n | monster madness
 019 |  C   | 2 | 2 | 3 |   |   | y
 020 |  C   | 2 | 2 | 1 |   |   | n | weird block bounceback trick
 021 |  C   | 2 | 2 | 2 |   |   | n | not lynx - fake exit
 022 |  D   |   |   |   |   |   | n
 023 |  G   |   |   |   |   |   | n | see 001
 024 |  D   |   |   |   |   |   | n | can't finish in time
 025 |  D   |   |   |   |   |   | n | some trick?
 026 |  G   |   |   |   |   |   | n | running around with monsters (revolver)
 027 |  G   |   |   |   |   |   | n | too much monster avoid at the beginning
 028 |  x   | 3 | 2 | 3 |   |   | y
 029 |  D   |   |   |   |   |   | n
 030 |  x   |   |   |   |   |   | n | can't get past teeth? (teeth herder)
 031 |  x   | 3 | 3 | 2 |   |   | y
 032 |  x   |   |   |   |   |   | n | end level
 
 PetersTopTen
 ------------
  #  | code | d | p | e | l | t | c | notes
 ----------------------------------------------------
 001 |  x   |   |   |   |   |   | 
 002 |  x   | 2 | 3 | 1 |   |   | y
 003 |  x   | 3 | 3 | 2 |   |   | y
 004 |  x   | 3 | 2 | 3 |   |   | y
 005 |  x   | 2 | 2 | 2 |   |   | y | not lynx compatible
 006 |  x   | 3 | 3 | 2 |   |   | y
 007 |  x   | 1 | 2 | 1 |   |   | n | (interlude) teleport trick
 008 |  x   |   |   |   |   |   | 
 009 |  x   | 4 | 2 | 4 |   |   | y | not lynx compatible
 010 |  x   |   |   |   |   |   | 

 petercclp3
 ------------
  #  | code | d | p | e | l | t | c | notes
 ----------------------------------------------------
 001 |  D   |   |   |   |   |   |   | from TopTen
 002 |  C   | 2 | 3 | 1 |   |   | y | from TopTen
 003 |  C   | 3 | 3 | 2 |   |   | y | from TopTen
 004 |  C   | 3 | 2 | 3 |   |   | y | from TopTen
 005 |  C   | 2 | 2 | 2 |   |   | y | from TopTen - fixed #5
 006 |  C   | 3 | 3 | 2 |   |   | y | from TopTen
 007 |  C   | 1 | 2 | 1 |   |   | n | from TopTen - (interlude) teleport trick
 008 |  A   |   |   |   |   |   |   | from TopTen
 009 |  C   | 4 | 2 | 4 |   |   | y | from TopTen - fixed #9
 010 |  D/G |   |   |   |   |   | n | from TopTen
 011 |  G   |   |   |   |   |   | n | M2 #1 - have to keep doing the same opening as it's easy to die later
 012 |  C   | 4 | 4 | 2 |   |   | y | M2 #2 - fixed
 013 |  C   | 3 | 2 | 3 |   |   | y | M2 #4
 014 |  C   | 2 | 2 | 2 |   |   | maybe  | M2 #5
 015 |  G   |   |   |   |   |   | n | M2 #8 - see 001
 016 |  G   |   |   |   |   |   | n | M2 #9 - mindless repetitive block pushing into bombs
 017 |  C   | 2 | 2 | 2 |   |   | y / maybe | M2 #11
 018 |  G   |   |   |   |   |   | n | M2 #15
 019 |  C   | 2 | 2 | 1 |   |   | y | M2 #16
 020 |  C   | 3 | 2 | 3 |   |   | y | M2 #28
 021 |  D   |   |   |   |   |   | n | M2 #30 - can't get past teeth? (teeth herder)
 022 |  C   | 3 | 3 | 2 |   |   | y | M2 #31
 023 |  I   |   |   |   |   |   | n | M2 #32 - end level

Public Domain Levelsets
=======================

 EricS1-pd
 ---------
 
 MikeL2
 ------

Others recommended at some point
================================ 
 BillR1
 ------
 
 BlakeE1
 -------
 
 CharlesH1
 ---------
 
 JimmyV1 (purpletentacle1977ca@yahoo.ca)
 -------
 
 MikeL2-fix
 ----------
 
 TCCLP
 -----
  #  | code | d | p | e | l | t | c | notes
 ----------------------------------------------------
 001 |  K   | 1 | 1 | 1 | 0 | 3 | n
 
 TCCLP2
 ------
 
 TomR1
 -----
 
 Xaser1
 ------
 
 */

#import "CCAdController.h"

@interface chipsAppDelegate : NSObject <UIApplicationDelegate, CCAdControllerDelegate> {
    UIWindow *window;
    BOOL firstTimeEver;
    
    UIView *splashView;
    UIView *activityView;
    
    BOOL loadingAlu;
    BOOL loadingController;
    BOOL displayingAlu;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

/*
 321 456
 546 321
 
 654 132
 132 564
 
 215 643
 463 215
 
 .. ..   12 43
 43 .2   43 12
 2. .4   21 34
 .. ..   34 21
*/
