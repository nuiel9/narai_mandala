extends TileMap

# Tile types
enum TileType {
	LAND = 0,
	RIVER = 1,
	CITY = 2
}

# Map dimensions
const MAP_WIDTH = 40
const MAP_HEIGHT = 20
const TILE_SIZE = 32

# Signals
signal map_changed()

func _ready():
	# Create TileSet at runtime if not already set
	if tile_set == null:
		create_tileset()
	
	# Generate initial map
	generate()

func create_tileset():
	"""Create a runtime TileSet with colored tiles"""
	var tileset = TileSet.new()
	
	# Create combined atlas texture (3 tiles horizontally)
	var atlas_image = Image.create(TILE_SIZE * 3, TILE_SIZE, false, Image.FORMAT_RGB8)
	
	# Fill each section with different colors
	# Land (0,0)
	var land_rect = Rect2i(0, 0, TILE_SIZE, TILE_SIZE)
	atlas_image.fill_rect(land_rect, Color("#2a3b2a"))
	
	# River (32,0)
	var river_rect = Rect2i(TILE_SIZE, 0, TILE_SIZE, TILE_SIZE)
	atlas_image.fill_rect(river_rect, Color("#2a4d7a"))
	
	# City (64,0)
	var city_rect = Rect2i(TILE_SIZE * 2, 0, TILE_SIZE, TILE_SIZE)
	atlas_image.fill_rect(city_rect, Color("#b79b4a"))
	
	# Create atlas texture
	var atlas_texture = ImageTexture.new()
	atlas_texture.set_image(atlas_image)
	
	# Create atlas source
	var atlas_source = TileSetAtlasSource.new()
	atlas_source.texture = atlas_texture
	atlas_source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	
	# Add tiles to atlas source
	for i in range(3):
		atlas_source.create_tile(Vector2i(i, 0))
	
	# Add atlas source to tileset
	tileset.add_source(atlas_source, 0)
	
	# Apply tileset to this TileMap
	tile_set = tileset


func generate(seed_value: int = 0):
	"""Generate the map with land, river, and cities"""
	# Set up random seed
	if seed_value == 0:
		seed_value = randi()
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	
	# Clear existing map
	clear()
	
	# Fill with land first
	fill_land()
	
	# Generate river
	generate_river(rng)
	
	# Place cities
	place_cities(rng)
	
	# Emit signal
	map_changed.emit()

func fill_land():
	"""Fill entire map with land tiles"""
	for x in range(MAP_WIDTH):
		for y in range(MAP_HEIGHT):
			set_cell(0, Vector2i(x, y), 0, Vector2i(TileType.LAND, 0))

func generate_river(rng: RandomNumberGenerator):
	"""Generate a winding river from top-left to bottom-right"""
	var start_x = rng.randi_range(2, 8)
	var start_y = 0
	var current_x = start_x
	var current_y = start_y
	
	# Create river path
	var river_points = []
	
	while current_y < MAP_HEIGHT - 1:
		river_points.append(Vector2i(current_x, current_y))
		
		# Move down and occasionally left/right
		current_y += 1
		
		# Random drift (-1, 0, 1)
		var drift = rng.randi_range(-1, 1)
		current_x = clamp(current_x + drift, 1, MAP_WIDTH - 2)
		
		# Bias toward bottom-right
		if rng.randf() < 0.3:
			current_x = min(current_x + 1, MAP_WIDTH - 2)
	
	# Add final point
	river_points.append(Vector2i(current_x, current_y))
	
	# Draw river tiles
	for point in river_points:
		set_cell(0, point, 0, Vector2i(TileType.RIVER, 0))
		# Add some width variation
		if rng.randf() < 0.4:
			var width_offset = rng.randi_range(-1, 1)
			var wide_point = Vector2i(point.x + width_offset, point.y)
			if is_valid_position(wide_point):
				set_cell(0, wide_point, 0, Vector2i(TileType.RIVER, 0))

func place_cities(rng: RandomNumberGenerator):
	"""Place cities randomly, avoiding water tiles"""
	var cities_placed = 0
	var attempts = 0
	var max_attempts = 100
	
	while cities_placed < 3 and attempts < max_attempts:
		var pos = Vector2i(
			rng.randi_range(1, MAP_WIDTH - 2),
			rng.randi_range(1, MAP_HEIGHT - 2)
		)
		
		# Check if position is valid (not on water)
		if not is_water(pos):
			set_cell(0, pos, 0, Vector2i(TileType.CITY, 0))
			cities_placed += 1
		
		attempts += 1

func is_valid_position(pos: Vector2i) -> bool:
	"""Check if position is within map bounds"""
	return pos.x >= 0 and pos.x < MAP_WIDTH and pos.y >= 0 and pos.y < MAP_HEIGHT

func world_to_tile(pos: Vector2i) -> Vector2i:
	"""Convert world position to tile coordinates"""
	return Vector2i(pos.x / TILE_SIZE, pos.y / TILE_SIZE)

func is_water(tile_pos: Vector2i) -> bool:
	"""Check if a tile position contains water"""
	if not is_valid_position(tile_pos):
		return false
		
	var tile_data = get_cell_atlas_coords(0, tile_pos)
	return tile_data.x == TileType.RIVER