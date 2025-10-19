# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Development Commands

### Running the Game
```bash
# Run in editor (primary development mode)
${GODOT_BIN:-godot} --path . scenes/world/Main.tscn

# Initialize/refresh Godot project files
${GODOT_BIN:-godot} --headless --editor --path . --quit
```

### Building
```bash
# Export web build (requires Export Templates installed via Editor > Manage Export Templates...)
mkdir -p build/web && ${GODOT_BIN:-godot} --headless --path . --export-release "Web" build/web/index.html
```

### Testing
```bash
# Run automated tests
${GODOT_BIN:-godot} --path . -s scripts/tests/test_runner.gd

# Manual testing in-game:
# Next turn: Press Enter/Space (ui_accept action)
# Game runs for 8 turns maximum before game over
```

## Project Architecture

### Core Systems (Autoloaded Singletons)
Load order from `project.godot`:
- **Turn** (`scripts/systems/turn_manager.gd`) - Handles turn progression and seasonal cycles
- **Market** (`scripts/systems/market.gd`) - Controls commodity pricing and market dynamics
- **Diplomacy** (`scripts/systems/diplomacy.gd`) - Faction relationship management
- **Events** (`scripts/systems/event_manager.gd`) - Random event system loading from JSON data
- **Game** (`scripts/systems/game_state.gd`) - Manages prestige, stability, and silver stats

### Signal-Based Communication
The project uses Godot's signal system extensively for loose coupling:
- `Turn.turn_advanced(current_turn, season_index, season_name)` - Broadcast turn changes
- `Game.stats_changed(prestige, stability, silver)` - UI updates for player stats
- `Market.price_changed(goods, new_price)` - Market fluctuation notifications

### Data Structure
```
data/
├── events/events.json     # Random events with effects
├── factions/factions.json # Diplomatic factions (Dutch, French, Persian)
└── items/goods.json       # Tradeable commodities
```

### Scene Organization
```
scenes/
├── ui/TopBar.tscn        # HUD displaying turn, stats
└── world/Main.tscn       # Primary game scene (entry point)

scripts/
├── systems/              # Autoloaded singleton systems
├── tests/test_runner.gd  # Automated test suite
├── ui/top_bar.gd        # TopBar scene controller
└── world/main.gd        # Main scene controller
```

### Game Flow
1. Main scene initializes and connects to system signals
2. Each turn triggers market price drift and random events
3. Events can modify faction relationships, market prices, and player stats
4. Player receives +5 silver each turn automatically
5. Player advances turns with Enter/Space until 8-turn limit
6. Game features Thai seasonal names: ต้นฝน, ปลายฝน, หนาว, ร้อน

### Key Variables & Ranges
- **Prestige**: 0-999 (clamped)
- **Stability**: -100 to 100 (clamped)  
- **Silver**: 0+ (no upper limit)
- **Market prices**: Dynamic based on base prices with ±10% drift
- **Seasons**: 4-season cycle with Thai names
- **Game length**: 8 turns maximum

### Development Notes
- Use `GODOT_BIN` environment variable to specify Godot executable path
- Thai text is used throughout for cultural authenticity
- Event effects are applied via string-based matching in `event_manager.gd`
- All systems communicate through signals, avoid direct references between systems
- Market price factors can be applied by events (e.g., monsoon affecting timber/hides)