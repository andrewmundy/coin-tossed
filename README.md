# Flipper - Coin Flip Roguelike

A pixel-art coin flipping roguelike built with LÖVE2D!

## How to Run

Make sure you have LÖVE2D installed, then:

just drag the `Flipper` folder onto the LÖVE application.

## Controls

- **Click the coin** or **press SPACE** to flip
- **ESC** to quit
- **SPACE** on game over screen to restart

## Game Rules

- Each flip costs nothing but could earn you money!
- **Heads**: Earn $10
- **Tails**: Earn nothing, adds to consecutive tails counter
- **Edge Landing** (1% chance): Earn $1000 and reset tails counter!
- **Lose**: Get 3 consecutive tails in a row

## Project Structure

```
Flipper/
├── main.lua              # Main game entry point
├── conf.lua              # LÖVE configuration
├── states/               # Game states
│   ├── playing.lua       # Main gameplay state
│   └── gameover.lua      # Game over screen
├── entities/             # Game entities
│   └── coin.lua          # Coin entity with animation
├── utils/                # Utilities
│   └── gamestate.lua     # Simple state manager
└── assets/               # Assets folder (empty for now)
    ├── images/
    ├── fonts/
    └── sounds/
```

## Next Steps

See `rules/action-plan.md` for the full development roadmap!

- Phase 2: Local scoreboard and stats
- Phase 3: Power meter mechanics
- Phase 4: Shop and cards system
- Phase 5: Full card catalog
- Phase 6: Meta-progression

---

**Happy Flipping!** 🪙

