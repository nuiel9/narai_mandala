extends Control
@onready var lbl_turn: Label = $HBox/Turn
@onready var lbl_prestige: Label = $HBox/Prestige
@onready var lbl_stability: Label = $HBox/Stability
@onready var lbl_silver: Label = $HBox/Silver
func _ready() -> void:
    Turn.connect("turn_advanced", Callable(self, "_on_turn"))
    Game.connect("stats_changed", Callable(self, "_on_stats"))
    _on_turn(Turn.current_turn, Turn.season_index, Turn.season_names[Turn.season_index])
    _on_stats(Game.prestige, Game.stability, Game.silver)
func _on_turn(cur:int, _sidx:int, sname:String) -> void:
    lbl_turn.text = "Turn %d / ฤดู: %s" % [cur, sname]
func _on_stats(prestige:int, stability:int, silver:int) -> void:
    lbl_prestige.text = "Prestige: %d" % prestige
    lbl_stability.text = "Stability: %d" % stability
    lbl_silver.text = "Silver: %d" % silver
