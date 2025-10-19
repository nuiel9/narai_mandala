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
# Next turn: Press Enter/Space/N (ui_accept or next_turn action)
# Trade: Press T to open/close trade panel
# Save: Ctrl+S (Cmd+S on macOS)
# Load: Ctrl+L (Cmd+L on macOS)
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
- **SaveLoad** (`scripts/systems/save_load.gd`) - ConfigFile-based game state persistence

### Signal-Based Communication
The project uses Godot's signal system extensively for loose coupling:
- `Turn.turn_advanced(current_turn, season_index, season_name)` - Broadcast turn changes
- `Game.stats_changed(prestige, stability, silver)` - UI updates for player stats
- `Market.price_changed(goods, new_price)` - Market fluctuation notifications
- `Diplomacy.relation_changed(faction, favor, fear, profit)` - Faction relationship updates
- `Map.map_changed()` - World map generation/regeneration notifications

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
├── ui/
│   ├── TopBar.tscn       # HUD displaying turn, stats
│   └── TradePanel.tscn   # Enhanced trading interface
└── world/
    ├── Main.tscn         # Primary game scene (entry point)
    └── Map.tscn          # TileMap-based world representation

scripts/
├── systems/              # Autoloaded singleton systems
├── tests/test_runner.gd  # Automated test suite
├── ui/
│   ├── top_bar.gd       # TopBar scene controller
│   └── trade_panel.gd   # Trade Panel with inventory & transaction log
└── world/
    ├── main.gd          # Main scene controller
    └── map.gd           # TileMap generation and management
```

### Game Flow
1. Main scene initializes and connects to system signals
2. Map generates procedural world with land, rivers, and cities
3. Each turn triggers market price drift and random events
4. Player can:
   - Trade goods via Trade Panel (T key) with inventory tracking
   - Save game state (Ctrl+S) or load previous save (Ctrl+L)
   - View real-time market price changes with visual feedback
5. Events can modify faction relationships, market prices, and player stats
6. Player receives +5 silver each turn automatically
7. Player advances turns with Enter/Space/N until 8-turn limit
8. Game features Thai seasonal names: ต้นฝน, ปลายฝน, หนาว, ร้อน

### Key Variables & Ranges
- **Prestige**: 0-999 (clamped)
- **Stability**: -100 to 100 (clamped)  
- **Silver**: 0+ (no upper limit)
- **Market prices**: Dynamic based on base prices with ±10% drift
- **Inventory**: Player goods storage (Dictionary by goods type)
- **Map dimensions**: 40x20 tiles (32x32 pixel tiles)
- **Tile types**: LAND(#2a3b2a), RIVER(#2a4d7a), CITY(#b79b4a)
- **Seasons**: 4-season cycle with Thai names
- **Game length**: 8 turns maximum
- **Transaction log**: Last 10 trades displayed

### Development Notes
- Use `GODOT_BIN` environment variable to specify Godot executable path
- Thai text is used throughout for cultural authenticity
- Event effects are applied via string-based matching in `event_manager.gd`
- All systems communicate through signals, avoid direct references between systems
- Market price factors can be applied by events (e.g., monsoon affecting timber/hides)
- ConfigFile save system stores all game state in `user://save.cfg`
- TileMap uses runtime-generated TileSet (no asset dependencies)
- Trade Panel tracks first-time trades for prestige bonuses
- Auto-refresh toggle provides visual price change feedback
