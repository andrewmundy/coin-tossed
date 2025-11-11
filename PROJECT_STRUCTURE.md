# Project Structure

This document describes the organized project structure for Flipper, which supports multiple game modes (Coin Mode and Battle Mode) with shared components.

## Directory Organization

```
Flipper/
├── main.lua                 # Main game entry point
├── config.lua               # Shared game configuration
├── conf.lua                 # LÖVE configuration
│
├── entities/                # Game entities
│   ├── shared/              # Shared entities (used by both modes)
│   │   └── powermeter.lua   # Power meter (used in coin mode, can be reused)
│   ├── coin/                # Coin Mode specific entities
│   │   └── coin.lua         # Coin entity
│   └── battle/              # Battle Mode specific entities
│       ├── player.lua      # Player entity
│       ├── enemy.lua        # Enemy entity
│       └── weapon.lua       # Weapon entity
│
├── states/                  # Game states
│   ├── shared/              # Shared states (used by both modes)
│   │   ├── intro.lua        # Intro/menu screen
│   │   ├── settings.lua     # Settings/pause menu
│   │   └── gameover.lua     # Game over screen
│   ├── coin/                # Coin Mode states
│   │   ├── playing.lua      # Coin mode gameplay
│   │   └── shop.lua        # Coin mode shop
│   └── battle/              # Battle Mode states
│       └── playing.lua     # Battle mode gameplay (placeholder)
│
├── systems/                 # Game systems/logic
│   ├── shared/              # Shared systems
│   │   └── cards.lua        # Card system (used by both modes)
│   ├── coin/                # Coin Mode systems
│   │   └── coins.lua        # Coin upgrade system
│   └── battle/              # Battle Mode systems (placeholder)
│
├── ui/                      # UI components
│   ├── shared/              # Shared UI components
│   ├── coin/                # Coin Mode UI components
│   └── battle/              # Battle Mode UI components
│       ├── healthbar.lua    # Health bar display
│       └── staminabar.lua  # Stamina bar display
│
├── utils/                   # Utility modules
│   ├── gamestate.lua        # State manager
│   └── responsive.lua      # Responsive layout utilities
│
└── assets/                  # Game assets
    ├── fonts/
    ├── images/
    ├── shaders/
    └── sounds/
```

## Module Paths

### Shared Components
- Entities: `require("entities.shared.powermeter")`
- States: `require("states.shared.intro")`
- Systems: `require("systems.shared.cards")`

### Coin Mode Components
- Entities: `require("entities.coin.coin")`
- States: `require("states.coin.playing")`
- Systems: `require("systems.coin.coins")`

### Battle Mode Components
- Entities: `require("entities.battle.player")`
- States: `require("states.battle.playing")`
- Systems: `require("systems.battle.*")` (to be implemented)

## Design Principles

1. **Separation of Concerns**: Each game mode has its own directory
2. **Shared Resources**: Common components are in `shared/` directories
3. **Clear Naming**: Paths clearly indicate which mode a component belongs to
4. **Extensibility**: Easy to add new game modes or shared components

## Adding New Components

### Adding a Shared Component
Place in the appropriate `shared/` directory:
- `entities/shared/` for shared entities
- `states/shared/` for shared states
- `systems/shared/` for shared systems

### Adding a Mode-Specific Component
Place in the appropriate mode directory:
- `entities/coin/` or `entities/battle/` for entities
- `states/coin/` or `states/battle/` for states
- `systems/coin/` or `systems/battle/` for systems

## Current Status

- ✅ Coin Mode: Fully implemented
- 🚧 Battle Mode: Placeholder structure created, ready for implementation

