extends Node2D

const MAP_SIZE: Vector2i = Vector2i(50, 50)
const TILE_GRASS: int = 0
const TILE_CITY: int = 5
const TILE_CAMILGTON: int = 8

@onready var tile_map: TileMap = $TileMap
@onready var player: CharacterBody2D = $Player
@onready var roll_button: Button = $UI/HUD/ActionPanel/RollButton

func _ready():
	generate_world()
	player.global_position = tile_map.map_to_local(Vector2i(25, 25))
	player.current_cell = Vector2i(25, 25)
	roll_button.hide()

func generate_world():
	for x in range(MAP_SIZE.x):
		for y in range(MAP_SIZE.y):
			tile_map.set_cell(0, Vector2i(x, y), TILE_GRASS)
	tile_map.set_cell(0, Vector2i(25, 30), TILE_CAMILGTON)
	tile_map.set_cell(0, Vector2i(10, 15), TILE_CITY)
