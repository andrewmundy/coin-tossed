# **Coin Flip Roguelike \- Game Design Document**

## **Core Concept**

A web-based incremental roguelike where players flip a coin to earn money, purchase upgrades, and create powerful synergies. Each run ends when the player accumulates 3 consecutive tails (or meets other loss conditions), encouraging strategic upgrade choices and risk management.

---

## **Core Loop**

1. **Click to flip coin**
2. **Earn money based on outcome** (heads/tails/edge)
3. **Every 5 flips, upgrade shop appears** with random selection of upgrade cards
4. **Choose upgrades** to add to cardset or level up existing cards
5. **Build synergies** to maximize scoring potential
6. **Lose after 3 consecutive tails** (or variant loss condition)
7. **Try to beat high score**

---

## **Value Vectors**

### **1\. Base Money (Primary)**

- **Heads**: Earn money based on coin level
- **Tails**: Earn 0 (or modified by upgrades)
- **Edge Landing**: Rare jackpot multiplier (100x+ base value)

### **2\. Streak/Combo System**

- Consecutive heads multiply value
- Broken by tails (unless protected by upgrades)
- Creates risk/reward tension

### **3\. Pattern Recognition**

- Specific sequences (HHT, THH, TTH, etc.) unlock bonuses
- More complex patterns \= bigger rewards
- Adds strategic depth to seemingly random flips

### **4\. Power Meter (Golf-style)**

A fluctuating meter that affects flip value based on timing:

**Meter Zones:**

- **Dead Zone** (5%): No flip, lose turn
- **Weak** (20%): 0.5x value
- **Normal** (40%): 1x value
- **Power** (25%): 1.5x value
- **Perfect** (10%): 3x value \+ guaranteed heads

### **5\. Heat/Temperature**

- Coin heats up with consecutive flips
- Temperature affects probability curves and multipliers
- Can be positive or negative depending on build

### **6\. Edge Landing (Rare Event)**

- Base 1% chance (0.5% starting)
- Massive multiplier bonus (100x)
- Doesn't count toward loss conditions, resets tails counter
- Centerpiece of thickness upgrade path

---

## **Loss Conditions**

### **Standard Mode**

- Accumulate 3 consecutive tails and game ends
- Final score calculated

### **Variant Modes (Potential)**

- **Money Target**: Reach X money in 10 flips or lose

---

## **Upgrade Card System**

### **Shop Mechanics**

- **Appears every 5 flips**
- **5 random cards offered** each time
- **Max of 5 upgrade cards**
- **Choose 1 card** (or skip if none desired)
- Cards can be:
  - **New cards** (add to your deck/build)
  - **Upgrades** to existing cards (level up)
- **Rarity system**: Common, Uncommon, Rare, Legendary
- **Card Combination**: If 2 cards can be combined, create a combined card leaving one more slot for upgrade

---

## **Upgrade Cards & Level Progression**

### **1\. VALUE MANIPULATION CARDS**

#### **Golden Flip (Common)**

_Increases the base value of heads_

- **Level 1**: Heads worth \+$5
- **Level 2**: Heads worth \+$12 (total)
- **Level 3**: Heads worth \+$25 (total)
- **Level 4**: Heads worth \+$50 (total)
- **Level 5**: Heads worth \+$100 (total)

#### **Silver Lining (Uncommon)**

_Tails aren't completely worthless anymore_

- **Level 1**: Tails worth $2
- **Level 2**: Tails worth $6
- **Level 3**: Tails worth $15
- **Level 4**: Tails worth $35
- **Level 5**: Tails worth $75

#### **Midas Touch (Rare)**

_Universal multiplier to all earnings_

- **Level 1**: 1.25x multiplier to all money earned
- **Level 2**: 1.5x multiplier
- **Level 3**: 2x multiplier
- **Level 4**: 3x multiplier
- **Level 5**: 5x multiplier

#### **Equilibrium (Legendary)**

_When tails value exceeds heads value, swap their probabilities_

- **Level 1**: Effect activates
- **Level 2**: When active, gain additional 1.5x multiplier
- **Level 3**: When active, gain 2x multiplier
- **Level 4**: When active, gain 3x multiplier
- **Level 5**: When active, gain 5x multiplier \+ guaranteed edge next flip

---

### **2\. PROBABILITY ENGINEERING CARDS**

#### **Weighted Coin (Common)**

_Tips the odds in your favor_

- **Level 1**: \+5% heads chance
- **Level 2**: \+8% heads chance (13% total)
- **Level 3**: \+12% heads chance (25% total)
- **Level 4**: \+15% heads chance (40% total)
- **Level 5**: \+20% heads chance (60% total)

#### **Lucky Charm (Uncommon)**

_Guarantees success at intervals_

- **Level 1**: Every 7th flip guaranteed heads
- **Level 2**: Every 6th flip guaranteed heads
- **Level 3**: Every 5th flip guaranteed heads
- **Level 4**: Every 4th flip guaranteed heads
- **Level 5**: Every 3rd flip guaranteed heads

#### **First Impression (Rare)**

_Start strong_

- **Level 1**: First flip always heads
- **Level 2**: First 2 flips always heads
- **Level 3**: First 3 flips always heads
- **Level 4**: First 4 flips always heads \+ 2x value
- **Level 5**: First 5 flips always heads \+ 3x value

#### **Balanced Odds (Legendary)**

_Embrace true randomness for great reward_

- **Level 1**: If you have exactly 50% heads chance, gain 2x multiplier
- **Level 2**: 50/50 odds give 3x multiplier
- **Level 3**: 50/50 odds give 4x multiplier \+ edge chance \+2%
- **Level 4**: 50/50 odds give 6x multiplier \+ edge chance \+4%
- **Level 5**: 50/50 odds give 10x multiplier \+ edge chance \+8%

---

### **3\. STREAK/COMBO CARDS**

#### **Momentum (Common)**

_Consecutive heads build power_

- **Level 1**: Each consecutive head adds \+0.1x multiplier (stacking)
- **Level 2**: Each consecutive head adds \+0.15x multiplier
- **Level 3**: Each consecutive head adds \+0.25x multiplier
- **Level 4**: Each consecutive head adds \+0.4x multiplier
- **Level 5**: Each consecutive head adds \+0.6x multiplier

#### **Streak Shield (Uncommon)**

_Protect your hard-earned combos_

- **Level 1**: One tails per run doesn't break streak
- **Level 2**: Two tails per run don't break streak
- **Level 3**: Three tails per run don't break streak
- **Level 4**: Tails never break streak, but still count toward loss
- **Level 5**: Tails extend streak by 1 instead of breaking it

#### **Cash Out (Rare)**

_Manually end streak for massive bonus_

- **Level 1**: End streak for 2x current streak value
- **Level 2**: End streak for 3x current streak value
- **Level 3**: End streak for 4x current streak value
- **Level 4**: End streak for 6x current streak value
- **Level 5**: End streak for 10x current streak value \+ keeps streak

#### **Phoenix Streak (Legendary)**

_Turn failure into success_

- **Level 1**: When streak breaks, gain permanent \+0.1x multiplier
- **Level 2**: When streak breaks, gain permanent \+0.2x multiplier
- **Level 3**: When streak breaks, gain permanent \+0.4x multiplier
- **Level 4**: When streak breaks, gain permanent \+0.7x multiplier \+ $100
- **Level 5**: When streak breaks, gain permanent \+1x multiplier \+ $500

---

### **4\. POWER METER CARDS**

#### **Steady Hands (Common)**

_Easier to hit your marks_

- **Level 1**: Meter speed reduced by 15%
- **Level 2**: Meter speed reduced by 25%
- **Level 3**: Meter speed reduced by 35%
- **Level 4**: Meter speed reduced by 45%
- **Level 5**: Meter speed reduced by 60%

#### **Sharpshooter (Uncommon)**

_Bigger target, better results_

- **Level 1**: Perfect zone \+2% size
- **Level 2**: Perfect zone \+4% size
- **Level 3**: Perfect zone \+7% size
- **Level 4**: Perfect zone \+10% size
- **Level 5**: Perfect zone \+15% size \+ removed dead zone

#### **Reverse Psychology (Rare)**

_Weak becomes strong_

- **Level 1**: Weak zone becomes 1x (normal)
- **Level 2**: Weak zone becomes 1.25x
- **Level 3**: Weak zone becomes 1.5x (power)
- **Level 4**: Weak zone becomes 2x
- **Level 5**: Weak zone becomes 3x (perfect)

#### **Perfect Form (Legendary)**

_Mastery of timing_

- **Level 1**: Hitting Perfect zone twice in a row \= 5x multiplier
- **Level 2**: Two Perfects \= 7x multiplier
- **Level 3**: Two Perfects \= 10x multiplier
- **Level 4**: Two Perfects \= 15x multiplier \+ guaranteed heads
- **Level 5**: Two Perfects \= 25x multiplier \+ guaranteed heads \+ edge chance \+5%

---

### **5\. COIN THICKNESS (EDGE LANDING) CARDS**

#### **Thick Wallet (Common)**

_A slightly chunkier coin_

- **Level 1**: Edge chance \+0.1% (1.1% total)
- **Level 2**: Edge chance \+0.2% (1.3% total)
- **Level 3**: Edge chance \+0.3% (1.6% total)
- **Level 4**: Edge chance \+0.5% (2.1% total)
- **Level 5**: Edge chance \+0.7% (2.8% total)

#### **Engineer's Pride (Uncommon)**

_Precision-machined thickness_

- **Level 1**: Edge chance \+0.5% (1.5% total)
- **Level 2**: Edge chance \+0.8% (2.3% total)
- **Level 3**: Edge chance \+1.2% (3.5% total)
- **Level 4**: Edge chance \+1.7% (5.2% total)
- **Level 5**: Edge chance \+2.5% (7.7% total)

#### **Magnetic Rim (Rare)**

_Edge landings synergize with streaks_

- **Level 1**: Edge landing extends current streak by 2
- **Level 2**: Edge landing extends streak by 4
- **Level 3**: Edge landing extends streak by 6
- **Level 4**: Edge landing extends streak by 8 \+ edge value 150x
- **Level 5**: Edge landing extends streak by 10 \+ edge value 200x

#### **Compound Interest (Rare)**

_Each edge makes the next more valuable_

- **Level 1**: Each edge this run adds \+50x to next edge value
- **Level 2**: Each edge adds \+100x to next edge
- **Level 3**: Each edge adds \+200x to next edge
- **Level 4**: Each edge adds \+400x to next edge
- **Level 5**: Each edge adds \+1000x to next edge

#### **On the Edge (Legendary)**

_Danger breeds opportunity_

- **Level 1**: Each tails adds \+0.3% edge chance (resets on edge)
- **Level 2**: Each tails adds \+0.5% edge chance
- **Level 3**: Each tails adds \+0.8% edge chance
- **Level 4**: Each tails adds \+1.2% edge chance \+ tails give 50% of edge value
- **Level 5**: Each tails adds \+2% edge chance \+ tails give 100% of last edge value

---

### **6\. PATTERN RECOGNITION CARDS**

#### **Pattern Seeker (Uncommon)**

_Unlock the art of pattern recognition_

- **Level 1**: Unlock 3-flip patterns (HHT, THH, etc.) \- $50 bonus
- **Level 2**: Patterns give $100 bonus
- **Level 3**: Patterns give $200 bonus
- **Level 4**: Patterns give $400 bonus \+ next flip 2x
- **Level 5**: Patterns give $800 bonus \+ next 3 flips 2x

#### **Pattern Master (Rare)**

_Longer sequences, bigger rewards_

- **Level 1**: Unlock 4-flip patterns \- $150 bonus
- **Level 2**: 4-flip patterns give $300 bonus
- **Level 3**: 4-flip patterns give $600 bonus
- **Level 4**: 4-flip patterns give $1200 bonus \+ 3x multiplier
- **Level 5**: 4-flip patterns give $2500 bonus \+ 5x multiplier

#### **Tails Tell Tales (Rare)**

_Patterns with tails are worth more_

- **Level 1**: Patterns containing tails give 1.5x value
- **Level 2**: Patterns with tails give 2x value
- **Level 3**: Patterns with tails give 3x value
- **Level 4**: Patterns with tails give 4x value \+ edge chance \+1%
- **Level 5**: Patterns with tails give 6x value \+ edge chance \+2%

#### **Grand Architect (Legendary)**

_Master of all patterns_

- **Level 1**: Complete 3 different patterns for $500 mega bonus
- **Level 2**: 3 patterns for $1000 mega bonus
- **Level 3**: 3 patterns for $2000 mega bonus \+ 5x multiplier
- **Level 4**: 3 patterns for $4000 mega bonus \+ 8x multiplier
- **Level 5**: 3 patterns for $8000 mega bonus \+ 10x multiplier \+ guaranteed edge

---

### **7\. SAFETY NET CARDS**

#### **Nine Lives (Common)**

_Extra room for error_

- **Level 1**: Need 4 consecutive tails to lose (instead of 3\)
- **Level 2**: Need 5 consecutive tails to lose
- **Level 3**: Need 6 consecutive tails to lose
- **Level 4**: Need 7 consecutive tails to lose
- **Level 5**: Need 8 consecutive tails to lose

#### **Tails Insurance (Uncommon)**

_First tails are free_

- **Level 1**: First tails of run doesn't count
- **Level 2**: First 2 tails don't count
- **Level 3**: First 3 tails don't count
- **Level 4**: First 4 tails don't count
- **Level 5**: First 5 tails don't count \+ they give $50 each

#### **Alchemy (Rare)**

_Turn lead into gold_

- **Level 1**: Third consecutive tails transforms to heads worth 5x
- **Level 2**: Third tails becomes heads worth 10x
- **Level 3**: Third tails becomes heads worth 20x
- **Level 4**: Third tails becomes heads worth 40x \+ guaranteed edge next flip
- **Level 5**: Third tails becomes heads worth 100x \+ next 3 flips guaranteed heads

#### **Underdog (Legendary)**

_Thrive under pressure_

- **Level 1**: At 2 consecutive tails, all earnings 2x
- **Level 2**: At 2 tails, earnings 3x \+ heads chance \+10%
- **Level 3**: At 2 tails, earnings 4x \+ heads chance \+15%
- **Level 4**: At 2 tails, earnings 6x \+ heads chance \+20% \+ edge chance \+2%
- **Level 5**: At 2 tails, earnings 10x \+ heads chance \+30% \+ edge chance \+5%

---

### **8\. META-PROGRESSION CARDS**

#### **Starting Capital (Common)**

_Begin runs with money in pocket_

- **Level 1**: Start each run with $50
- **Level 2**: Start with $125
- **Level 3**: Start with $250
- **Level 4**: Start with $500
- **Level 5**: Start with $1000

#### **Legacy (Rare)**

_Past success breeds future success_

- **Level 1**: Each run's final score adds \+0.05% permanent multiplier
- **Level 2**: Final score adds \+0.1% permanent multiplier
- **Level 3**: Final score adds \+0.2% permanent multiplier
- **Level 4**: Final score adds \+0.4% permanent multiplier
- **Level 5**: Final score adds \+1% permanent multiplier

#### **Prestige (Legendary)**

_Reset everything for ultimate power_

- **Level 1**: Reset all progress, gain \+0.5x permanent multiplier
- **Level 2**: Reset, gain \+1x permanent multiplier
- **Level 3**: Reset, gain \+2x permanent multiplier
- **Level 4**: Reset, gain \+4x permanent multiplier
- **Level 5**: Reset, gain \+10x permanent multiplier \+ start with 5 random max-level cards

---

### **9\. SYNERGY/COMBO CARDS**

#### **Perfect Balance (Rare)**

_True randomness rewards greatly_

- **Level 1**: When lifetime heads/tails ratio is 50/50, edge chance triples
- **Level 2**: At 50/50, edge chance x4
- **Level 3**: At 50/50, edge chance x5 \+ all earnings 2x
- **Level 4**: At 50/50, edge chance x7 \+ all earnings 3x
- **Level 5**: At 50/50, edge chance x10 \+ all earnings 5x

#### **Edge Memory (Rare)**

_Edge landings echo forward_

- **Level 1**: Next flip after edge landing is guaranteed heads
- **Level 2**: Next 2 flips guaranteed heads
- **Level 3**: Next 3 flips guaranteed heads
- **Level 4**: Next 3 flips guaranteed heads worth 2x
- **Level 5**: Next 5 flips guaranteed heads worth 3x

#### **Insurance Payout (Uncommon)**

_Patience pays off_

- **Level 1**: Every non-edge flip adds \+0.5x to next edge value
- **Level 2**: Every non-edge adds \+1x to next edge
- **Level 3**: Every non-edge adds \+2x to next edge
- **Level 4**: Every non-edge adds \+4x to next edge
- **Level 5**: Every non-edge adds \+10x to next edge

#### **Chaos Theory (Legendary)**

_Embrace randomness_

- **Level 1**: Each flip has 10% chance for random bonus (0.5x to 5x)
- **Level 2**: 15% chance, range 0.5x to 8x
- **Level 3**: 20% chance, range 1x to 12x
- **Level 4**: 25% chance, range 1x to 20x \+ can trigger edge
- **Level 5**: 33% chance, range 2x to 50x \+ can trigger guaranteed edge

---

## **Card Rarity & Drop Rates**

### **Shop Appearance Rates (per card slot):**

- **Common**: 50% chance
- **Uncommon**: 30% chance
- **Rare**: 15% chance
- **Legendary**: 5% chance

### **Card Selection Strategy:**

- If you already own a card, it can appear as an upgrade option
- New cards vs. upgrades weighted based on your current deck size
- Early game (0-10 cards): 70% new, 30% upgrades
- Mid game (11-20 cards): 50% new, 50% upgrades
- Late game (21+ cards): 30% new, 70% upgrades

---

## **Synergy Philosophy**

### **Design Principles:**

1. **Combinations should feel clever**, not obvious
2. **Some synergies should enable entirely new strategies** (edge build, pattern build, streak build)
3. **Anti-synergies exist** for balance (some upgrades conflict)
4. **Diminishing returns on stacking** similar upgrades
5. **Discovery is rewarding** \- players experiment to find combinations

### **Example Build Archetypes:**

**"Edge Lord" Build:**

- Thick Wallet \+ Engineer's Pride (max thickness)
- Compound Interest \+ Magnetic Rim
- On the Edge
- Insurance Payout

**"Streak Master" Build:**

- Momentum \+ Streak Shield
- Cash Out \+ Phoenix Streak
- Pattern Seeker (for bonus money during streaks)
- First Impression (strong start)

**"Perfect Timing" Build:**

- Steady Hands \+ Sharpshooter
- Perfect Form \+ Reverse Psychology
- Midas Touch (multiply perfect bonuses)

**"Safe & Steady" Build:**

- Nine Lives \+ Tails Insurance
- Underdog (thrive at 2 tails)
- Silver Lining (tails have value)
- Alchemy (convert 3rd tails)

**"Pattern Recognition" Build:**

- Pattern Seeker \+ Pattern Master
- Tails Tell Tales
- Grand Architect
- Streak Shield (patterns trigger during streaks)

**"Balanced Chaos" Build:**

- Balanced Odds (50/50 bonus)
- Perfect Balance (50/50 edge boost)
- Chaos Theory
- Don't buy Weighted Coin (stay at 50%)

---

## **Dual Currency System (Optional)**

### **Money (Primary)**

- Earned from flips
- Used for most upgrades
- Run-specific

### **Luck Tokens (Secondary)**

- Earned from achievements, patterns, edge landings
- Used for rare/powerful upgrades
- Persistent between runs (optional)

**Currency Bridge Synergies:**

- "Convert excess money to luck at 100:1 ratio"
- "Spend luck to guarantee next edge landing"

---

## **UI/UX Considerations**

### **Core Interface:**

- Large, clickable coin in center
- pixel art style
- Money counter (prominent)
- Tails counter / loss warning
- Current multipliers display
- Card collection display (side or bottom)

### **Upgrade Shop (Every 5 Flips):**

- 5 cards presented
- Clear display of:
  - Card name & rarity
  - Current level (if owned)
  - Next level effects
  - Cost (if any)
  - Synergy indicators (glowing border if combos with owned cards)
- "Skip" option
- Tooltips explaining mechanics

### **Power Meter:**

- Visible meter moving during flips
- Color-coded zones
- Clear visual feedback on success/failure

### **Visual Feedback:**

- Coin thickness visually increases
- Edge landing has dramatic animation
- Streak counter with visual flair
- Screen shake/particles for big wins
- Card collection shows owned cards

---

## **Progression & Difficulty Curve**

### **Early Game (Flips 1-20):**

- Learning mechanics
- First few shop visits
- Common/Uncommon cards mostly
- Low stakes, building understanding

### **Mid Game (Flips 21-50):**

- Synergies start to matter
- Must choose build direction
- Rare cards appearing
- Risk management becomes critical

### **Late Game (Flips 51+):**

- Fully realized build
- High multipliers, big scores
- Legendary cards in play
- One mistake can end run
- Edge landings or perfect execution required for high scores

---

## **Future Expansion Ideas**

### **Additional Card Sets:**

- Seasonal/themed cards
- Event-exclusive cards
- Achievement-unlocked cards

### **Additional Coin Types:**

- **Lucky Coin**: Higher edge chance, lower value
- **Cursed Coin**: Negative effects but massive payouts
- **Ancient Coin**: Three-sided (heads/tails/ancient symbol)

### **Challenge Modes:**

- Time attack
- Limited flips
- Specific build constraints (only common cards, no safety nets, etc.)
- Daily challenges with preset card pools

---

## **Technical Considerations**

### **Core Technologies:**

- HTML/CSS/JavaScript
- React (for state management and UI)
- Authentication and accounts for high scores and meta-progression
- Smooth animations for coin flip and meter

### **Performance:**

- Responsive animations
- Save state between sessions
- Card collection persistence

### **Accessibility:**

- Keyboard controls option
- Colorblind-friendly UI
- Adjustable animation speed

---

## **Monetization (Optional)**

- Cosmetic coin skins
- Cosmetic card backs/frames
- Starting boost packs
- Purely cosmetic, no pay-to-win

---

## **Success Metrics**

- Average run length
- Card diversity (are players using different builds?)
- Most popular card combinations
- High score progression
- Return player rate
- Time spent per session
- Shop skip rate (are cards interesting?)

---

## **Summary**

This game combines the simple satisfaction of coin flipping with deep strategic choices through a card-based upgrade system. The shop appearing every 5 flips creates natural decision points and pacing. The edge landing mechanic provides a hilarious, meme-worthy progression path, while card synergies ensure varied gameplay. The roguelike structure encourages experimentation and creates "just one more run" addiction.

**Core Appeal:** Easy to learn, hard to master, endlessly replayable, satisfying synergy discovery through card combinations.
