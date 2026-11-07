extends Node2D

const MAP_SIZE: Vector2i = Vector2i(50, 50)
const CELL_SIZE: Vector2i = Vector2i(16, 16)

const TILE_GRASS: int = 0
const TILE_FOREST: int = 1
const TILE_MOUNTAIN: int = 2
const TILE_WATER: int = 3
const TILE_ROAD: int = 4
const TILE_CITY: int = 5
const TILE_DUNGEON: int = 6
const TILE_CAVE: int = 7
const TILE_CAMILGTON: int = 8

var locations: Dictionary = {
	"cities": [
		{"name": "Kamiltgon", "pos": Vector2i(25, 30), "type": TILE_CAMILGTON},
		{"name": "Molakha", "pos": Vector2i(10, 15), "type": TILE_CITY},
	],
	"dungeons": [
		{"name": "Табір культистів", "pos": Vector2i(5, 20), "type": TILE_DUNGEON, "monsters": ["cultist", "adept"]},
		{"name": "Печера Каплоса", "pos": Vector2i(45, 5), "type": TILE_CAVE, "monsters": ["necromancer", "shadow_assassin", "cult_leader"]},
	],
}

@onready var tile_map: TileMap = $TileMap
@onready var player: CharacterBody2D = $Player
@onready var ui: CanvasLayer = $UI
@onready var hud: Control = $UI/HUD
@onready var hp_label: Label = $UI/HUD/StatsPanel/HPLabel
@onready var mp_label: Label = $UI/HUD/StatsPanel/MPLabel
@onready var position_label: Label = $UI/HUD/StatsPanel/PositionLabel
@onready var dice_result_label: Label = $UI/HUD/DicePanel/DiceResultLabel

func _ready():
	generate_world()
	if GameManager.current_player:
		player = GameManager.current_player
	player.global_position = cell_to_world(Vector2i(25, 25))
	player.current_cell = Vector2i(25, 25)
	update_ui()
	player.connect("player_moved", Callable(self, "_on_player_moved"))

func generate_world():
	for x in range(MAP_SIZE.x):
		for y in range(MAP_SIZE.y):
			tile_map.set_cell(0, Vector2i(x, y), TILE_GRASS)
	for x in range(5, 15):
		for y in range(10, 20):
			if randf() > 0.3:
				tile_map.set_cell(0, Vector2i(x, y), TILE_FOREST)
	for x in range(35, 50):
		for y in range(0, 10):
			if randf() > 0.5:
				tile_map.set_cell(0, Vector2i(x, y), TILE_MOUNTAIN)
	for x in range(20, 30):
		tile_map.set_cell(0, Vector2i(x, 25), TILE_WATER)
		tile_map.set_cell(0, Vector2i(x, 26), TILE_WATER)
	for x in range(10, 25):
		tile_map.set_cell(0, Vector2i(x, 15), TILE_ROAD)
	for y in range(15, 30):
		tile_map.set_cell(0, Vector2i(25, y), TILE_ROAD)
	for city in locations["cities"]:
		tile_map.set_cell(0, city["pos"], city["type"])
	for dungeon in locations["dungeons"]:
		tile_map.set_cell(0, dungeon["pos"], dungeon["type"])

func world_to_cell(world_pos: Vector2) -> Vector2i:
	return tile_map.local_to_map(world_pos)

func cell_to_world(cell_pos: Vector2i) -> Vector2:
	return tile_map.map_to_local(cell_pos)

func is_cell_walkable(cell_pos: Vector2i) -> bool:
	var cell_id = tile_map.get_cell_source_id(0, cell_pos)
	return cell_id in [TILE_GRASS, TILE_FOREST, TILE_ROAD, TILE_CITY, TILE_DUNGEON, TILE_CAVE, TILE_CAMILGTON]

func get_cell_terrain(cell_pos: Vector2i) -> String:
	var cell_id = tile_map.get_cell_source_id(0, cell_pos)
	match cell_id:
		TILE_GRASS: return "grass"
		TILE_FOREST: return "forest"
		TILE_MOUNTAIN: return "mountain"
		TILE_WATER: return "water"
		TILE_ROAD: return "road"
		TILE_CITY: return "city"
		TILE_DUNGEON: return "dungeon"
		TILE_CAVE: return "cave"
		TILE_CAMILGTON: return "city"
		_: return "unknown"

func _on_player_moved(new_cell: Vector2i):
	player.current_cell = new_cell
	update_ui()
	for dungeon in locations["dungeons"]:
		if dungeon["pos"] == new_cell:
			enter_dungeon(dungeon["name"])
			return
	for city in locations["cities"]:
		if city["pos"] == new_cell:
			enter_city(city["name"])
			return
	if randf() < 0.1:
		random_encounter()

func enter_dungeon(dungeon_name: String):
	print("Вхід до данжу: ", dungeon_name)
	GameManager.load_dungeon(dungeon_name)

func enter_city(city_name: String):
	print("Вхід до міста: ", city_name)
	GameManager.load_city(city_name)

func random_encounter():
	print("Випадкова зустріч!")
	GameManager.load_combat(["cultist", "zombie"])

func _on_roll_button_pressed():
	var roll = DiceSystem.roll_d6()
	dice_result_label.text = "Кубик d6: %d" % [roll]
	var direction = Vector2i(randi() % 3 - 1, randi() % 3 - 1)
	var target_cell = player.current_cell + direction * roll
	if is_cell_walkable(target_cell):
		player.move_to_cell(target_cell)

func _on_move_button_pressed():
	var target_cell = player.current_cell + Vector2i(1, 0)
	if is_cell_walkable(target_cell):
		player.move_to_cell(target_cell)

func update_ui():
	if player:
		hp_label.text = "HP: %d/%d" % [player.hp, player.max_hp]
		mp_label.text = "MP: %d/%d" % [0, 0]
		position_label.text = "Position: (%d, %d)" % [player.current_cell.x, player.current_cell.y]

func _process(delta):
	update_ui()
