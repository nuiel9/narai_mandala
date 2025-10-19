extends SceneTree
# เรียกด้วย: godot --path . -s scripts/tests/test_runner.gd

var passed := 0
var failed := 0

func _init():
    print("Running Narai Mandala Tests...")
    run_tests()
    print("Tests passed: %d, failed: %d" % [passed, failed])
    quit()

func run_tests():
    # Test file existence and basic loading
    test_file_structure()
    
    # Test optional systems if they exist
    if ResourceLoader.exists("res://scripts/systems/utils_money.gd"):
        test_utils_money()
    else:
        print("[SKIP] utils_money.gd not found")
        
    if ResourceLoader.exists("res://scripts/systems/combat.gd"):
        test_combat_system()
    else:
        print("[SKIP] combat.gd not found")

func test_file_structure():
    var required_files = [
        "res://scripts/systems/game_state.gd",
        "res://scripts/systems/turn_manager.gd", 
        "res://scripts/systems/market.gd",
        "res://scripts/systems/diplomacy.gd",
        "res://scripts/systems/event_manager.gd"
    ]
    
    for file in required_files:
        _assert(ResourceLoader.exists(file), "File exists: " + file)
    
    var data_files = [
        "res://data/events/events.json",
        "res://data/factions/factions.json",
        "res://data/items/goods.json"
    ]
    
    for file in data_files:
        _assert(FileAccess.file_exists(file), "Data file exists: " + file)

func test_utils_money():
    var script = load("res://scripts/systems/utils_money.gd")
    if script:
        # Test static method if implemented correctly
        if script.has_method("format_money"):
            var result = script.format_money(1234567)
            _assert(result == "฿1,234,567", "utils_money.format_money works")
        else:
            print("[INFO] utils_money.format_money method not found")
    else:
        print("[FAIL] Could not load utils_money.gd")

func test_combat_system():
    var script = load("res://scripts/systems/combat.gd")
    if script:
        var instance = script.new()
        if instance.has_method("start_skirmish"):
            var result = instance.start_skirmish(100, 80, "plain")
            _assert(typeof(result) == TYPE_DICTIONARY, "combat returns dictionary")
            if typeof(result) == TYPE_DICTIONARY:
                _assert(result.has("result"), "combat result has 'result' key")
        else:
            print("[INFO] combat.start_skirmish method not found")
    else:
        print("[FAIL] Could not load combat.gd")

func _assert(cond:bool, name:String) -> void:
    if cond:
        print("[OK]   ", name)
        passed += 1
    else:
        print("[FAIL] ", name)
        failed += 1
