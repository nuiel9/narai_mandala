extends Node
signal relation_changed(faction:String, favor:int, fear:int, profit:int)
var factions := {
    "dutch":{"favor":30,"fear":40,"profit":50},
    "fr":{"favor":35,"fear":25,"profit":40},
    "persia":{"favor":45,"fear":15,"profit":55}
}
func get_relation(f:String) -> Dictionary: return factions.get(f, {})
func adjust(f:String, k:String, delta:int) -> void:
    if factions.has(f) and factions[f].has(k):
        factions[f][k] = clampi(factions[f][k] + delta, 0, 100)
        var d: Dictionary = factions[f]; emit_signal("relation_changed", f, d["favor"], d["fear"], d["profit"])
func apply_treaty(t:String, target:String) -> void:
    match t:
        "port_rights": adjust(target,"favor",10); Game.add_prestige(1)
        "mil_advisor": adjust(target,"favor",8);  Game.add_stability(2)
        "trade_privilege": adjust(target,"profit",12); Game.add_silver(10)
        _: pass
