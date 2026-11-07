extends Node2D

const CITY_SIZE: Vector2i = Vector2i(30, 30)
const CELL_SIZE: Vector2i = Vector2i(16, 16)

const TILE_ROAD: int = 0
const TILE_BUILDING: int = 1
const TILE_PARK: int = 2
const TILE_MARKET: int = 3

@onready var tile_map: TileMap = $TileMap
@onready var player: CharacterBody2D = $Player

var city_name: String = ""

func _ready():
	generate_city()
	if GameManager.current_player:
		player = GameManager.current_player
	player.global_position = cell_to_world(Vector2i(15, 15))
	player.current_cell = Vector2i(15, 15)

func generate_city():
	# Generate a simple city layout
	for x in range(CITY_SIZE.x):
		for y in range(CITY_SIZE.y):
			tile_map.set_cell(0, Vector2i(x, y), TILE_ROAD)
	# Add buildings
	for x in range(5, 25, 5):
		for y in range(5, 25, 5):
			if randf() > 0.3:
				tile_map.set_cell(0, Vector2i(x, y), TILE_BUILDING)
	# Add central park
	for x in range(12, 18):
		for y in range(12, 18):
			tile_map.set_cell(0, Vector2i(x, y), TILE_PARK)
	# Add market
	for x in range(20, 25):
		for y in range(5, 10):
			tile_map.set_cell(0, Vector2i(x, y), TILE_MARKET)

func world_to_cell(world_pos: Vector2) -> Vector2i:
	return tile_map.local_to_map(world_pos)

func cell_to_world(cell_pos: Vector2i) -> Vector2:
	return tile_map.map_to_local(cell_pos)

func is_cell_walkable(cell_pos: Vector2i) -> bool:
	var cell_id = tile_map.get_cell_source_id(0, cell_pos)
	return cell_id == TILE_ROAD or cell_id == TILE_PARK or cell_id == TILE_MARKET
