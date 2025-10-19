extends Node
signal stats_changed(prestige:int, stability:int, silver:int)
var prestige:int = 0
var stability:int = 50
var silver:int = 100
func _ready() -> void:
    emit_signal("stats_changed", prestige, stability, silver)
func add_prestige(v:int) -> void:
    prestige = clampi(prestige + v, 0, 999); emit_signal("stats_changed", prestige, stability, silver)
func add_stability(v:int) -> void:
    stability = clampi(stability + v, -100, 100); emit_signal("stats_changed", prestige, stability, silver)
func add_silver(v:int) -> void:
    silver = max(0, silver + v); emit_signal("stats_changed", prestige, stability, silver)
