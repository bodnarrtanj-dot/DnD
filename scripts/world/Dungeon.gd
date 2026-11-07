extends Node2D

const DUNGEON_SIZE: Vector2i = Vector2i(20, 20)
const CELL_SIZE: Vector2i = Vector2i(16, 16)

const TILE_FLOOR: int = 0
const TILE_WALL: int = 1
const TILE_DOOR: int = 2
const TILE_TRAP: int = 3
const TILE_TREASURE: int = 4

@onready var tile_map: TileMap = $TileMap
@onready var player: CharacterBody2D = $Player

func _ready():
	generate_dungeon()
	if GameManager.current_player:
		player = GameManager.current_player
	player.global_position = cell_to_world(Vector2i(10, 10))
	player.current_cell = Vector2i(10, 10)

func generate_dungeon():
	# Generate a simple dungeon layout
	for x in range(DUNGEON_SIZE.x):
		for y in range(DUNGEON_SIZE.y):
			if x == 0 or y == 0 or x == DUNGEON_SIZE.x - 1 or y == DUNGEON_SIZE.y - 1:
				tile_map.set_cell(0, Vector2i(x, y), TILE_WALL)
			else:
				tile_map.set_cell(0, Vector2i(x, y), TILE_FLOOR)
	# Add some walls inside
	for x in range(5, 15):
		tile_map.set_cell(0, Vector2i(x, 5), TILE_WALL)
	for y in range(10, 15):
		tile_map.set_cell(0, Vector2i(5, y), TILE_WALL)

func world_to_cell(world_pos: Vector2) -> Vector2i:
	return tile_map.local_to_map(world_pos)

func cell_to_world(cell_pos: Vector2i) -> Vector2:
	return tile_map.map_to_local(cell_pos)

func is_cell_walkable(cell_pos: Vector2i) -> bool:
	var cell_id = tile_map.get_cell_source_id(0, cell_pos)
	return cell_id == TILE_FLOOR or cell_id == TILE_DOOR or cell_id == TILE_TREASURE
