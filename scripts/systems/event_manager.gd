extends Node
var events:Array = []
func _ready() -> void: _load_events()
func _load_events() -> void:
    if not FileAccess.file_exists("res://data/events/events.json"): return
    var f := FileAccess.open("res://data/events/events.json", FileAccess.READ)
    if f:
        var parsed = JSON.parse_string(f.get_as_text())
        if typeof(parsed) == TYPE_ARRAY: events = parsed
func roll_event() -> Dictionary:
    if events.is_empty(): return {}
    return events[randi() % events.size()]
func apply_event(ev:Dictionary) -> void:
    match ev.get("id",""):
        "monsoon": Market.apply_price_factor({"timber":1.1,"hides":1.1}); Game.add_stability(-2)
        "ambassy_foreign": Diplomacy.adjust("fr","favor",10); Diplomacy.adjust("dutch","fear",5); Game.add_prestige(2)
        "court_rumor": Game.add_stability(-3)
        _: pass
