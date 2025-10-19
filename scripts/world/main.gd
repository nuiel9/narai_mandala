extends Node2D
func _ready() -> void:
    Turn.connect("turn_advanced", Callable(self, "_on_turn_advanced"))
    Turn.connect("game_over", Callable(self, "_on_game_over"))
    Market.drift_prices()
func _unhandled_input(event:InputEvent) -> void:
    if event.is_action_pressed("ui_accept"): Turn.next_turn() # Enter/Space
func _on_turn_advanced(cur:int, _sidx:int, _sname:String) -> void:
    Market.drift_prices()
    var ev := Events.roll_event()
    if not ev.is_empty(): Events.apply_event(ev)
    Game.add_silver(5)
func _on_game_over() -> void:
    print("Game Over — Jam Slice Summary")
