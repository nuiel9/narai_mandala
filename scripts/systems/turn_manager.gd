extends Node
signal turn_advanced(current_turn:int, season_index:int, season_name:String)
signal game_over
var current_turn: int = 1
var max_turns: int = 8
var season_names := ["ต้นฝน","ปลายฝน","หนาว","ร้อน"]
var season_index: int = 0
func _ready() -> void:
    emit_signal("turn_advanced", current_turn, season_index, season_names[season_index])
func next_turn() -> void:
    current_turn += 1
    season_index = (season_index + 1) % season_names.size()
    if current_turn > max_turns:
        emit_signal("game_over"); return
    emit_signal("turn_advanced", current_turn, season_index, season_names[season_index])
