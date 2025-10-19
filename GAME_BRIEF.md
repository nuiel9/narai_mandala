# Narai Mandala — Game Jam Brief (Top-down Strategy, Godot 4)

## สรุป (TH)
เกมวางแผนมุมมองบน ผสม 2D/3D ตั้งในยุคสมเด็จพระนารายณ์ ผู้เล่นบริหาร 3 ระบบ: การรบ การค้า การทูต
โครงหลัก: 8 เทิร์นตามฤดูกาล ชนะด้วย Prestige และ Stability ตามเกณฑ์ แพ้เมื่อ Stability < 0 เมืองล่ม หรือโดนคว่ำบาตร 2 ฝ่าย
สโคป Jam: โทเคนยูนิต 2D, ระบบเบา, เล่นบนเว็บ, โค้ด GDScript 4, ใช้สัญญาณ (signals) เชื่อม UI
ไม่ทำ: pathfinding ซับซ้อน, AI หนัก, แอสเซ็ตใหญ่

## Summary (EN)
Top-down strategy set in Ayutthaya (King Narai era). Three pillars: War, Trade, Diplomacy.
Core loop: 8 seasonal turns. Win via Prestige & Stability thresholds. Fail if Stability < 0, capital falls, or dual embargo.
Jam scope: 2D tokens, RTwP-lite feel, Web export, GDScript 4, signal-driven UI. 
Non-goals: fancy pathfinding, heavy AI, large assets.

### Systems (MVP)
- Turn: current_turn 1..8, seasons rotate ["ต้นฝน","ปลายฝน","หนาว","ร้อน"].
- Market: goods = [rice, timber, tin, hides, sappan, silver], ±10% drift per turn, event modifiers allowed.
- Diplomacy: factions = dutch, fr, persia; metrics = favor, fear, profit; simple treaties (port_rights, mil_advisor, trade_privilege).
- Events: JSON-driven, ~10 cards (e.g., monsoon, embassy, court_rumor).
- Win/Lose: see above.

### Tech Rules
- Godot 4 (GDScript). Signals for UI updates. Keep files small and testable.
- Export Web (HTML5). One main scene: scenes/world/Main.tscn.
- Data in JSON under /data.
