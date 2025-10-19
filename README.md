# Narai Mandala

A top-down strategy game set in Ayutthaya during the reign of King Narai, featuring trade, diplomacy, and resource management mechanics.

## 🎮 Game Features

- **8-Turn Campaign**: Play through seasonal cycles with Thai season names (ต้นฝน, ปลายฝน, หนาว, ร้อน)
- **Trading System**: Buy and sell 6 commodities with dynamic pricing and inventory management
- **Procedural World**: 40x20 tile map with procedurally generated rivers and cities
- **Save/Load**: Complete game state persistence using ConfigFile
- **Real-time Market**: Price fluctuations with visual feedback and transaction history
- **Cultural Authenticity**: Thai seasonal names and historical context

## 🚀 Quick Start

### Running the Game
```bash
# Run in editor (development mode)
${GODOT_BIN:-godot} --path . scenes/world/Main.tscn

# Initialize Godot project files
${GODOT_BIN:-godot} --headless --editor --path . --quit
```

### Controls
- **T**: Open/Close Trade Panel
- **Ctrl+S** (⌘+S): Save Game
- **Ctrl+L** (⌘+L): Load Game
- **Enter/Space/N**: Advance Turn

### Building for Web
```bash
# Export web build (requires Export Templates)
mkdir -p build/web && ${GODOT_BIN:-godot} --headless --path . --export-release "Web" build/web/index.html
```
*Note: Install Export Templates via Editor > Manage Export Templates...*

## 🏗️ Architecture

### Core Systems
- **Turn Manager**: Seasonal progression and turn advancement
- **Market System**: Dynamic commodity pricing with drift mechanics
- **Game State**: Prestige, Stability, and Silver management
- **Diplomacy**: Faction relationship tracking (Dutch, French, Persian)
- **Events**: JSON-driven random events with stat effects
- **SaveLoad**: ConfigFile-based state persistence

### Tech Stack
- **Engine**: Godot 4.x
- **Language**: GDScript
- **Architecture**: Signal-driven autoloaded singletons
- **Data**: JSON configuration files
- **Graphics**: Runtime-generated TileMap with colored tiles

## 📁 Project Structure

```
narai_mandala/
├── scenes/
│   ├── ui/           # User interface scenes
│   └── world/        # Game world and main scene
├── scripts/
│   ├── systems/      # Core game systems (autoloaded)
│   ├── ui/           # UI controllers
│   ├── world/        # World management
│   └── tests/        # Automated test suite
├── data/             # JSON configuration files
└── .warp/            # Warp AI prompts and workflows
```

## 🎯 Game Flow

1. **Start**: Begin with initial resources (Prestige: 0, Stability: 50, Silver: 100)
2. **Trade**: Use Trade Panel to buy/sell goods, build inventory, earn prestige
3. **Events**: Random events affect market prices and player stats
4. **Advance**: Progress through 8 turns with automatic silver income
5. **Save/Load**: Preserve progress with full state persistence

## 🛠️ Development

### Testing
```bash
# Run automated tests
${GODOT_BIN:-godot} --path . -s scripts/tests/test_runner.gd
```

### Warp AI Integration
This project includes Warp AI prompts and workflows in `.warp/`:
- TileMap generation prompt
- Trade Panel enhancement prompt  
- Save/Load system prompt
- Clipboard workflows for easy reuse

## 📊 Game Stats

- **Prestige**: 0-999 (win condition)
- **Stability**: -100 to 100 (lose if < 0)
- **Silver**: Currency for trading (0+)
- **Commodities**: Rice, Timber, Tin, Hides, Sappan, Silver
- **Map**: 40x20 tiles with land, rivers, and cities

## 🎨 Assets

- **Graphics**: Runtime-generated colored tiles
- **UI**: Godot's built-in UI components
- **No external assets required**: Fully self-contained

## 📝 Documentation

- [WARP.md](WARP.md) - Development guide for Warp AI
- [progress.md](progress.md) - Development progress and status

## 🏛️ Historical Context

Set during the reign of King Narai the Great (1656-1688) of Ayutthaya, when the kingdom was a major trading hub connecting East and West, with significant diplomatic relations with European powers.

---

*Built with Godot 4.x • Optimized for web export • Game jam ready*
