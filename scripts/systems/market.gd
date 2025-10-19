extends Node
signal price_changed(goods:String, new_price:int)
var base_prices := {"rice":10,"timber":12,"tin":25,"hides":15,"sappan":20,"silver":35}
var prices := {}
var rng := RandomNumberGenerator.new()
func _ready() -> void:
    rng.randomize(); prices = base_prices.duplicate()
    for g in prices.keys(): emit_signal("price_changed", g, prices[g])
func get_price(goods:String) -> int: return prices.get(goods, 0)
func drift_prices() -> void:
    for g in prices.keys():
        var d := randi()%21 - 10 # -10..10
        prices[g] = max(1, base_prices[g] + int(round(base_prices[g]*d/100.0)))
        emit_signal("price_changed", g, prices[g])
func apply_price_factor(factors:Dictionary) -> void:
    for g in factors.keys():
        if prices.has(g):
            prices[g] = int(round(max(1.0, float(prices[g]) * float(factors[g]))))
            emit_signal("price_changed", g, prices[g])
