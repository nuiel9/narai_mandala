extends Node

# Save/Load system using ConfigFile

func _ready() -> void:
	print("SaveLoad system initialized")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("save_game"):
		save_game()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("load_game"):
		load_game()
		get_viewport().set_input_as_handled()

func save_game(path: String = "user://save.cfg") -> bool:
	"""Save current game state to ConfigFile"""
	var config = ConfigFile.new()
	
	# Save Turn system data
	config.set_value("turn", "current_turn", Turn.current_turn)
	config.set_value("turn", "season_index", Turn.season_index)
	
	# Save Game stats
	config.set_value("game", "prestige", Game.prestige)
	config.set_value("game", "stability", Game.stability)
	config.set_value("game", "silver", Game.silver)
	
	# Save Diplomacy data
	for faction_name in Diplomacy.factions.keys():
		var faction_data = Diplomacy.factions[faction_name]
		config.set_value("diplomacy", faction_name + "_favor", faction_data.favor)
		config.set_value("diplomacy", faction_name + "_fear", faction_data.fear)
		config.set_value("diplomacy", faction_name + "_profit", faction_data.profit)
	
	# Save Market prices
	for goods in Market.prices.keys():
		config.set_value("market", goods + "_price", Market.prices[goods])
	
	# Save metadata
	config.set_value("meta", "save_time", Time.get_datetime_string_from_system())
	config.set_value("meta", "version", "1.0")
	
	# Write to file
	var error = config.save(path)
	if error == OK:
		print("Game saved successfully to: ", path)
		return true
	else:
		push_warning("Failed to save game file: " + str(error))
		return false

func load_game(path: String = "user://save.cfg") -> bool:
	"""Load game state from ConfigFile"""
	var config = ConfigFile.new()
	
	# Check if save file exists
	if not FileAccess.file_exists(path):
		push_warning("Save file does not exist: " + path)
		return false
	
	# Load the config file
	var error = config.load(path)
	if error != OK:
		push_warning("Failed to load save file: " + str(error))
		return false
	
	# Load Turn system data
	if config.has_section("turn"):
		Turn.current_turn = config.get_value("turn", "current_turn", 1)
		Turn.season_index = config.get_value("turn", "season_index", 0)
	
	# Load Game stats
	if config.has_section("game"):
		Game.prestige = config.get_value("game", "prestige", 0)
		Game.stability = config.get_value("game", "stability", 50)
		Game.silver = config.get_value("game", "silver", 100)
	
	# Load Diplomacy data
	if config.has_section("diplomacy"):
		for faction_name in Diplomacy.factions.keys():
			if config.has_section_key("diplomacy", faction_name + "_favor"):
				Diplomacy.factions[faction_name].favor = config.get_value("diplomacy", faction_name + "_favor", Diplomacy.factions[faction_name].favor)
			if config.has_section_key("diplomacy", faction_name + "_fear"):
				Diplomacy.factions[faction_name].fear = config.get_value("diplomacy", faction_name + "_fear", Diplomacy.factions[faction_name].fear)
			if config.has_section_key("diplomacy", faction_name + "_profit"):
				Diplomacy.factions[faction_name].profit = config.get_value("diplomacy", faction_name + "_profit", Diplomacy.factions[faction_name].profit)
	
	# Load Market prices
	if config.has_section("market"):
		for goods in Market.prices.keys():
			if config.has_section_key("market", goods + "_price"):
				Market.prices[goods] = config.get_value("market", goods + "_price", Market.prices[goods])
	
	# Emit signals to update all UI components
	_refresh_all_signals()
	
	# Print load info
	var save_time = config.get_value("meta", "save_time", "Unknown")
	var version = config.get_value("meta", "version", "Unknown")
	print("Game loaded successfully from: ", path)
	print("Save time: ", save_time, " | Version: ", version)
	
	return true

func _refresh_all_signals() -> void:
	"""Refresh all system signals after loading"""
	# Refresh Turn signal
	var season_name = Turn.season_names[Turn.season_index] if Turn.season_index < Turn.season_names.size() else "Unknown"
	Turn.turn_advanced.emit(Turn.current_turn, Turn.season_index, season_name)
	
	# Refresh Game stats signal
	Game.stats_changed.emit(Game.prestige, Game.stability, Game.silver)
	
	# Refresh Diplomacy signals
	for faction_name in Diplomacy.factions.keys():
		var faction = Diplomacy.factions[faction_name]
		Diplomacy.relation_changed.emit(faction_name, faction.favor, faction.fear, faction.profit)
	
	# Refresh Market price signals
	for goods in Market.prices.keys():
		Market.price_changed.emit(goods, Market.prices[goods])

func has_save_file(path: String = "user://save.cfg") -> bool:
	"""Check if a save file exists"""
	return FileAccess.file_exists(path)

func delete_save_file(path: String = "user://save.cfg") -> bool:
	"""Delete save file"""
	if FileAccess.file_exists(path):
		var dir = DirAccess.open("user://")
		if dir:
			var error = dir.remove(path.get_file())
			if error == OK:
				print("Save file deleted: ", path)
				return true
			else:
				push_warning("Failed to delete save file: " + str(error))
				return false
	return false

func get_save_info(path: String = "user://save.cfg") -> Dictionary:
	"""Get information about a save file"""
	var info = {}
	
	if not FileAccess.file_exists(path):
		return info
	
	var config = ConfigFile.new()
	var error = config.load(path)
	if error != OK:
		return info
	
	info["save_time"] = config.get_value("meta", "save_time", "Unknown")
	info["version"] = config.get_value("meta", "version", "Unknown")
	info["current_turn"] = config.get_value("turn", "current_turn", 0)
	info["season_index"] = config.get_value("turn", "season_index", 0)
	info["prestige"] = config.get_value("game", "prestige", 0)
	info["stability"] = config.get_value("game", "stability", 0)
	info["silver"] = config.get_value("game", "silver", 0)
	
	return info