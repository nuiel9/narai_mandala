extends Node
# เรียกด้วย: godot --path . -s scripts/tests/test_runner.gd
func _init():
    var passed := 0
    var failed := 0
    # ลองโหลดไฟล์ยูทิลกับคอมแบต ถ้ามี
    if ResourceLoader.exists("res://scripts/systems/utils_money.gd"):
        var U = load("res://scripts/systems/utils_money.gd").new()
        var out = U.format_money(1234567)
        _assert(out == "฿1,234,567", "format_money basics", passed, failed)
    if ResourceLoader.exists("res://scripts/systems/combat.gd"):
        var C = load("res://scripts/systems/combat.gd").new()
        var r = C.start_skirmish(100, 80, "plain")
        _assert(typeof(r) == TYPE_DICTIONARY and r.has("result"), "combat returns dict", passed, failed)
    print("Tests passed: %d, failed: %d" % [passed, failed])
    get_tree().quit()
func _assert(cond:bool, name:String, passed: int, failed: int) -> void:
    if cond:
        print("[OK]   ", name)
        passed += 1
    else:
        push_error("[FAIL] " + name)
        failed += 1
