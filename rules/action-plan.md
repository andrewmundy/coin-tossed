# Coin Flip Roguelike - Development Action Plan (LÖVE2D)

## Overview

This plan breaks down development into 6 phases, starting with a simple MVP and progressively adding features to reach the full game vision.

wei### 🎮 Current Progress: ~15% Complete (2/6 Phases)

- ✅ **Phase 1 Complete**: Core coin flip mechanics with money tracking and loss conditions
- ✅ **Phase 3 Complete**: Power meter timing system with deterministic outcomes
- 🎨 **Polish Added**: Chunky pixel art aesthetic, 3D animations, visual feedback

### 🎯 What's Working Now:

- Clickable coin with realistic vertical 3D flip animation
- Power meter with cubic easing and oscillating timing indicator
- Deterministic zone system (Heads/Tails/Edge) with configurable multipliers
- Speed randomization after each flip to prevent muscle memory
- Punchy animations (bar bump, block lift, independent edge bounces)
- Balatro-inspired color scheme with layered shadows and depth effects
- Money tracking, consecutive tails counter, and game over conditions
- Git repository initialized with first commit

---

## Phase 1: MVP - Core Mechanics ✅ COMPLETED

**Goal:** Create a playable prototype with basic coin flip, money tracking, and loss conditions.

### Tasks:

1. **Project Setup**

   - [x] Set up LÖVE2D project structure (main.lua, conf.lua)
   - [x] Create folder structure (states/, entities/, utils/)
   - [x] Set up game configuration (window size, title, version)
   - [x] Create basic game loop (love.load, love.update, love.draw)
   - [x] Initialize git repository

2. **Core Game State**

   - [x] Create game state manager (playing, gameover)
   - [x] Implement coin flip logic (deterministic based on power meter)
   - [x] Create game state table (money, flips, consecutive_tails)
   - [x] Track flip history
   - [x] Implement state transitions

3. **Game Entities & Rendering**

   - [x] Create Coin entity (drawable, clickable, with 3D vertical flip animation)
   - [x] Create UI rendering for money display
   - [x] Create UI rendering for tails counter (warning at 2 tails)
   - [x] Create UI rendering for flips counter
   - [x] Create Game Over screen with final score
   - [x] Add restart functionality (R key)

4. **Game Logic**

   - [x] Implement coin flip function (deterministic via power meter zones)
   - [x] Calculate money earned (heads = $1, edge = 1.5x multiplier)
   - [x] Detect 3 consecutive tails loss condition
   - [x] Handle game over state
   - [x] Reset game state on restart

5. **Basic Visuals**
   - [x] Implement chunky pixel art UI aesthetic with shadows
   - [x] Set up pixel art rendering (nearest neighbor filtering)
   - [x] Implement realistic 3D vertical coin flip animation
   - [x] Create Balatro-inspired color scheme (red/blue/gold)
   - [x] Implement layered shadows and depth effects

**Deliverable:** ✅ A working game where you can click to flip, earn money, and lose after 3 consecutive tails. Features chunky pixel art aesthetic with smooth animations.

---

## Phase 2: Local Scoreboard & Stats

**Goal:** Add persistent local high scores and player statistics.

### Tasks:

1. **Local Save System**

   - [ ] Create save file structure using love.filesystem
   - [ ] Implement save function (serialize scores to file)
   - [ ] Implement load function (deserialize from file)
   - [ ] Handle missing/corrupted save files
   - [ ] Create default save data structure

2. **Score Tracking**

   - [ ] Create high score list (top 10 runs)
   - [ ] Save run details (score, flips, cards used, date)
   - [ ] Sort scores by money earned
   - [ ] Update high score list after each run
   - [ ] Display new high score notification

3. **Local Leaderboard UI**

   - [ ] Create leaderboard screen state
   - [ ] Render top 10 local scores
   - [ ] Display rank, score, flips, cards
   - [ ] Show date/time of each run
   - [ ] Highlight current session's score
   - [ ] Add "clear data" option

4. **Basic Stats Tracking**

   - [ ] Track total games played
   - [ ] Track total flips
   - [ ] Track total money earned (all-time)
   - [ ] Track best streak
   - [ ] Track total edge landings
   - [ ] Calculate heads/tails ratio

5. **Stats Screen**
   - [ ] Create stats screen state
   - [ ] Display lifetime statistics
   - [ ] Show personal bests
   - [ ] Display fun facts (first play date, etc.)
   - [ ] Add reset stats option (with confirmation)

**Deliverable:** Local high scores persist between sessions, players can view their personal records.

---

## Phase 3: Power Meter Mechanics ✅ COMPLETED

**Goal:** Add the golf-style timing mechanic for skilled play.

### Tasks:

1. **Power Meter Core**

   - [x] Create PowerMeter entity/module
   - [x] Implement animated meter bar with cubic easing curve
   - [x] Define zones (Heads, Tails, Edge) with configurable positions
   - [x] Calculate zone boundaries using helper functions and size constants
   - [x] Implement oscillating meter position with fast return animation
   - [x] Add meter speed configuration with ±25% randomization per flip

2. **Timing System**

   - [x] Detect mouse click timing (love.mousepressed)
   - [x] Calculate which zone the indicator was in
   - [x] Apply zone multiplier to flip value (deterministic outcomes)
   - [x] Edge zone: 1.5x multiplier with golden glow effect
   - [x] Heads zones: Blue blocks with 1.0x or 1.2x multipliers
   - [x] Tails zones: Auto-generated to fill gaps
   - [x] Store hit accuracy in game state

3. **Visual Feedback**

   - [x] Draw color-coded zones with 3D depth effects
   - [x] Draw moving indicator (growing bar with bright edge line)
   - [x] Create hit confirmation animation (punchy bump effect)
   - [x] Display zone result in floating box
   - [x] Add visual juice (bar bump, block lift animations)
   - [x] Draw meter with chunky shadows and borders
   - [x] Implement independent bounce animations for edge zones

4. **Power Meter Cards**

   - [ ] **Steady Hands** (Common): Reduce meter speed
   - [ ] **Sharpshooter** (Uncommon): Increase Perfect zone size
   - [ ] **Reverse Psychology** (Rare): Weak zone becomes strong
   - [ ] **Perfect Form** (Legendary): Bonus for consecutive perfects

5. **Integration**
   - [x] Integrate power meter with coin flip mechanics
   - [x] Update UI to show result information
   - [x] Add keyboard support (spacebar to flip)
   - [x] Speed randomization occurs after each flip
   - [x] Deterministic zone-based outcomes (no RNG for heads/tails)

**Deliverable:** ✅ Timing-based gameplay adds skill element to each flip. Power meter features cubic easing for challenge, deterministic outcomes, and satisfying visual feedback with independent animations for special zones.

---

## Phase 4: Upgrade Store & Basic Cards ✅ COMPLETED

**Goal:** Implement the shop system with card selection and a starter set of upgrade cards.

### Completed Implementation:

1. **Shop Mechanics** ✅

   - [x] Trigger shop every 10 flips (resets tails counter)
   - [x] Create shop game state with proper state management
   - [x] Pause game updates when shop is open
   - [x] Generate 3 random cards based on rarity weights (excluding maxed cards)
   - [x] Implement card selection with mouse click
   - [x] Add explicit close button (X in footer) - multiple purchases allowed
   - [x] Transition back to playing state with persistent game data
   - [x] **Coin upgrade system** in 4th slot (Bronze → Silver → Gold → Platinum → Diamond)
   - [x] **Card sell system** - right-click to sell for 50% refund

2. **Card System Foundation** ✅

   - [x] Create Cards module with complete structure (`systems/cards.lua`)
   - [x] Define card properties: id, name, description, rarity, effect, max_level
   - [x] Create card catalog with 8 different cards
   - [x] Track owned cards in game state (max 5 slots, always visible)
   - [x] **Card leveling system** (3 levels max, increasing effects)
   - [x] **Dynamic cost system** (Level 1: $5-15, Level 2: $50, Level 3: $100-300)
   - [x] Card effect application system with `Cards.applyEffects()`
   - [x] Display owned cards in shop with 5 slots (filled + empty placeholders)
   - [x] **Card slot management** with visual feedback

3. **Final Card Set (8 cards)** ✅

   - [x] **Golden Flip** (Common): +20%/+40%/+60% heads value per level
   - [x] **Weighted Coin** (Uncommon): Increases heads zone size (1.2x/1.4x/1.6x)
   - [x] **Nine Lives** (Legendary): Need 5 consecutive tails to lose (max level 1, no upgrades)
   - [x] **Silver Lining** (Common): Tails worth $0.10/$0.25/$0.50
   - [x] **Midas Touch** (Rare): +10%/+20%/+30% universal multiplier
   - [x] **Edge Master** (Rare): Increases edge zone size (1.5x/2.0x/2.5x)
   - [x] **Slow Motion** (Uncommon): Slows power meter (80%/65%/50% speed)
   - [x] **Lucky Strike** (Uncommon): Adds 1/2/3 extra small heads zones
   - [x] **Haggler** (Common): Shop cards cost 10%/20%/30% less

4. **Card Effects Implementation** ✅

   - [x] Create comprehensive effect system for all flip results
   - [x] Implement value multipliers (heads_value, universal, edge)
   - [x] Implement zone size modifiers (heads zones, edge zones)
   - [x] Implement extra heads zone generation (dynamic zone rebuilding)
   - [x] Implement loss condition modifiers (tails_limit = 5 with Nine Lives)
   - [x] Implement power meter speed modifiers
   - [x] Apply all active card effects to flips with proper stacking
   - [x] Display active effects in UI:
     - **COIN MULT** box (persistent card-based multiplier)
     - **STREAK** box (consecutive heads multiplier, halves on tails)
     - Both boxes bump on value changes
   - [x] **Alternating power meter speed** (0.8x-0.95x slow, 1.05x-1.2x fast)

5. **Shop UI Rendering** ✅
   - [x] Draw MS-DOS style shop screen with blue header and footer
   - [x] Render 3 card options at bottom + coin upgrade in 4th slot
   - [x] Draw card text with proper fonts (name, description, effect preview, cost)
   - [x] Show card rarity with background colors (Gray/Blue/Magenta/Yellow)
   - [x] **Level-based visual decorations:**
     - Level 2: Gold border + stars
     - Level 3: Gold + Cyan double border + more stars
   - [x] Hover effects (cards lift up, show "Click to Buy"/"Can't Afford")
   - [x] Draw owned cards in header with **5 slot system** (filled + empty)
   - [x] **Right-click to sell** with hover showing sell price
   - [x] Affordability indicators (dim cards, red cost when can't afford)
   - [x] MS-DOS aesthetic (16-color palette, solid backgrounds, no rounded corners)
   - [x] Money display centered in footer
   - [x] **Coin upgrade card-style** with circular coin graphic

**Additional Features:**

- Cards properly update cost/level after purchase in same shop session
- Maxed cards (Level 3) disappear from shop
- Sold cards can be repurchased from Level 1
- Card effects dynamically rebuild power meter zones
- Sound effects for purchases and upgrades
- Debug keys: 'S' to open shop, 'C' to toggle card details

**Deliverable:** ✅ Shop appears every 10 flips with 3 cards + coin upgrade. Players can buy multiple cards/upgrades per visit, sell unwanted cards, level up cards to 3 levels, and all cards significantly affect gameplay through stacking effects and zone modifications.

---

## Phase 5: Card Levels & Combinations

**Goal:** Implement full card progression system with leveling and combinations.

### Tasks:

1. **Card Leveling**

   - [ ] Allow selecting same card to level it up (Level 1-5)
   - [ ] Store card level in game state
   - [ ] Display current level on cards in collection
   - [ ] Show next level effects in shop
   - [ ] Implement all 5 levels for each card
   - [ ] Adjust shop weights (more upgrades in late game)

2. **Complete Card Catalog**

   - [ ] Implement all Value Manipulation cards (4 cards)
   - [ ] Implement all Probability Engineering cards (4 cards)
   - [ ] Implement all Streak/Combo cards (4 cards)
   - [ ] Implement all Power Meter cards (4 cards)
   - [ ] Implement all Coin Thickness/Edge cards (5 cards)
   - [ ] Implement all Pattern Recognition cards (4 cards)
   - [ ] Implement all Safety Net cards (4 cards)
   - [ ] Implement all Meta-Progression cards (3 cards)
   - [ ] Implement all Synergy/Combo cards (4 cards)

3. **Edge Landing Mechanic**

   - [ ] Implement edge landing (base 1% chance)
   - [ ] Edge landing pays 20x base value
   - [ ] Edge doesn't count toward loss
   - [ ] Edge resets tails counter
   - [ ] Visual animation for edge landing

4. **Card Combinations**

   - [ ] Detect compatible card pairs
   - [ ] Show combination option in shop
   - [ ] Create combined card (frees up 1 slot)
   - [ ] Implement combined card effects
   - [ ] Visual indicator for combinable cards

5. **Synergy Indicators**
   - [ ] Detect card synergies in shop
   - [ ] Highlight synergistic cards (glowing border)
   - [ ] Show synergy tooltips
   - [ ] Display active synergies during gameplay

**Deliverable:** Full card system with 36+ cards, leveling, and strategic depth.

---

## Phase 6: Persistent Store & Meta-Progression

**Goal:** Add cross-run progression and save system.

### Tasks:

1. **Save System**

   - [ ] Create save file structure using love.filesystem
   - [ ] Implement save function (serialize game state to file)
   - [ ] Implement load function (deserialize from file)
   - [ ] Auto-save every flip or on state change
   - [ ] Save current run state (money, cards, flips)
   - [ ] Save meta-progression data
   - [ ] Save settings and preferences
   - [ ] Handle save file corruption/missing files

2. **Meta-Progression Cards**

   - [ ] **Starting Capital**: Begin runs with money
   - [ ] **Legacy**: Score adds permanent multiplier
   - [ ] **Prestige**: Reset for permanent power
   - [ ] Store meta-progression in separate persistent file

3. **Persistent Stats**

   - [ ] Create stats tracking system
   - [ ] Track lifetime flips
   - [ ] Track lifetime money earned
   - [ ] Track total edge landings
   - [ ] Track heads/tails ratio
   - [ ] Save stats to file after each run
   - [ ] Create stats screen UI
   - [ ] Display stats with nice formatting

4. **Achievements System**

   - [ ] Define achievement list (table/module)
   - [ ] Track achievement progress in save file
   - [ ] Check for achievement unlocks after each flip
   - [ ] Create achievement notification popup
   - [ ] Display achievements in profile screen
   - [ ] Unlock rewards (cosmetics, cards)
   - [ ] Draw achievement icons/badges

5. **Dual Currency (Optional)**

   - [ ] Implement Luck Tokens system
   - [ ] Award tokens for achievements/edges
   - [ ] Create token shop screen
   - [ ] Currency conversion mechanics
   - [ ] Save token count persistently

6. **Settings & QoL**
   - [ ] Create settings screen state
   - [ ] Animation speed slider
   - [ ] Sound effects toggle
   - [ ] Music toggle
   - [ ] Volume controls (love.audio.setVolume)
   - [ ] Fullscreen toggle
   - [ ] Keyboard shortcuts display
   - [ ] Color blind mode
   - [ ] Tutorial/help screen with keyboard navigation
   - [ ] Save settings to file

**Deliverable:** Complete game with persistence, meta-progression, and polish.

---

## Post-Launch: Polish & Expansion

### Additional Features:

- [ ] Sound effects and music (using love.audio)
- [ ] More polished animations and particle effects
- [ ] Shader effects for visual polish (love.graphics.newShader)
- [ ] Daily challenges (local only)
- [ ] Challenge modes (time attack, limited flips, no power meter)
- [ ] Alternative coin types with different sprites
- [ ] Seasonal/event cards
- [ ] Cosmetic shop (coin skins, card backs, themes)
- [ ] Controller support (love.joystick)
- [ ] Build for multiple platforms (Windows, Mac, Linux)
- [ ] Itch.io distribution package
- [ ] Optional: Steam integration (Steamworks.NET wrapper)

### Analytics & Iteration:

- [ ] Track local player metrics (save to file)
- [ ] Monitor card usage statistics locally
- [ ] Export stats for balance analysis
- [ ] Playtest and gather feedback
- [ ] Community feedback implementation
- [ ] Optional: Anonymous usage data collection (opt-in)

---

## Technical Stack Recommendations

### Core:

- **LÖVE2D** (11.4 or later) - Lua game framework
- **Lua 5.1/LuaJIT** - Programming language
- **love.filesystem** - Save file management
- **love.graphics** - Rendering and drawing
- **love.audio** - Sound and music
- **love.math** - Random number generation

### Libraries (Optional):

- **JSON.lua** or **dkjson** - JSON encoding/decoding for save files
- **serpent** or **bitser** - Lua table serialization (alternative to JSON)
- **flux.lua** or **tween.lua** - Tweening/animation
- **hump** - Helper utilities (timer, camera, gamestate, etc.)
- **lume** - Lua utility functions
- **classic** or **middleclass** - OOP/class system
- **kikito/inspect.lua** - Pretty-print Lua tables for debugging

### Development Tools:

- **VS Code** with Lua extension
- **ZeroBrane Studio** - Lua IDE with debugger
- **love-release** - Build tool for packaging game
- **Git + GitHub** for version control
- **luacheck** - Lua linter for code quality

### Asset Tools:

- **Aseprite** or **Piskel** - Pixel art creation
- **Tiled** - Map editor (if needed for level design)
- **Audacity** or **BFXR** - Sound effect creation
- **BeepBox** or **Bosca Ceoil** - Music creation

---

## Timeline Estimates

| Phase                       | Estimated Time | Complexity | Status            |
| --------------------------- | -------------- | ---------- | ----------------- |
| Phase 1: MVP                | 3-5 days       | Low        | ✅ Complete       |
| Phase 2: Local Scores       | 2-3 days       | Low        | Not Started       |
| Phase 3: Power Meter        | 3-5 days       | Medium     | ✅ Complete       |
| Phase 4: Shop & Basic Cards | 1-2 weeks      | Medium     | Not Started       |
| Phase 5: Full Card System   | 3-4 weeks      | High       | Not Started       |
| Phase 6: Persistence & Meta | 1 week         | Medium     | Not Started       |
| **Total**                   | **7-10 weeks** | -          | **~15% Complete** |

_Note: Timeline assumes 1 developer working part-time. LÖVE2D's simplicity may speed up early prototyping. Adjust based on experience with Lua and team size._

---

## Success Criteria

### Phase 1 Success: ✅ ACHIEVED

- ✅ Can flip coin and earn money
- ✅ Game ends after 3 consecutive tails
- ✅ Can restart and play again
- ✅ Chunky pixel art style with shadows looks great

### Phase 2 Success: (Not Yet Started)

- ✓ Scores save and load correctly
- ✓ Local leaderboard displays top 10 runs
- ✓ Stats persist between sessions
- ✓ No data loss on game restart

### Phase 3 Success: ✅ ACHIEVED

- ✅ Power meter adds skill element
- ✅ Timing feels responsive and fair
- ✅ Edge hits are satisfying with special animations
- ✅ Animations are smooth and punchy
- ✅ Deterministic outcomes feel fair

### Phase 4 Success:

- ✓ Shop appears every 5 flips
- ✓ Cards visibly affect gameplay
- ✓ Players make strategic choices
- ✓ UI is clear and intuitive

### Phase 5 Success:

- ✓ Card synergies create diverse builds
- ✓ Players discover combinations
- ✓ Replayability is high
- ✓ All cards are balanced

### Phase 6 Success:

- ✓ Progress persists across sessions
- ✓ Meta-progression feels rewarding
- ✓ Players return for "one more run"
- ✓ Save system is reliable

---

## Next Steps

### Completed:

1. ✅ Reviewed and refined plan for LÖVE2D
2. ✅ Installed LÖVE2D
3. ✅ Set up project structure (states/, entities/, utils/)
4. ✅ Completed Phase 1: MVP with core mechanics
5. ✅ Completed Phase 3: Power meter with timing mechanics
6. ✅ Initialized git repository and made first commit

### Current Status:

- **MVP is playable** with coin flipping, money tracking, and power meter
- **Visual polish** includes chunky pixel art aesthetic with shadows and animations
- **Game feel** includes smooth animations, punchy feedback, and independent zone animations

### Recommended Next Phase:

**Option A: Phase 2 (Local Scoreboard & Stats)** - Add persistence and replay value

- Implement save system with love.filesystem
- Track high scores and statistics
- Add leaderboard display

**Option B: Phase 4 (Upgrade Store & Cards)** - Add core progression mechanics

- Implement shop system (appears every 5 flips)
- Create starter set of upgrade cards
- Add strategic depth to runs

Both options will significantly enhance replayability!

**Useful LÖVE2D Resources:**

- [Official LÖVE Wiki](https://love2d.org/wiki/Main_Page)
- [LÖVE Examples](https://github.com/love2d-community/awesome-love2d)
- [Lua Quick Reference](http://lua-users.org/wiki/LuaQuickReference)

Good luck building your coin flip roguelike! 🎮
