extends Node2D
## Overworld.gd - Карта світу

# Розмір карти (клітинок)
const MAP_SIZE: Vector2i = Vector2i(50, 50)

# Розмір клітинки (пікселів)
const CELL_SIZE: Vector2i = Vector2i(16, 16)

# Типи клітинок
@onready var TileTypes = {
	"GRASS": 0,
	"FOREST": 1,
	"MOUNTAIN": 2,
	"WATER": 3,
	"ROAD": 4,
	"CITY": 5,
	"DUNGEON": 6,
	"CAVE": 7,
	"CAMILGTON": 8
}

# Дані про локації
var locations: Dictionary = {
	"cities": [
		{"name": "Molakha", "pos": Vector2i(10, 15), "type": TileTypes["CITY"]},
		{"name": "Kamiltgon", "pos": Vector2i(25, 30), "type": TileTypes["CAMILGTON"]},
		{"name": "Onegata", "pos": Vector2i(40, 10), "type": TileTypes["CITY"]},
	],
	"dungeons": [
		{"name": "Табір культистів", "pos": Vector2i(5, 20), "type": TileTypes["DUNGEON"], "monsters": ["cultist", "adept"]},
		{"name": "Печера Каплоса", "pos": Vector2i(45, 5), "type": TileTypes["CAVE"], "monsters": ["necromancer", "shadow_assassin", "cult_leader"]},
		{"name": "Підземелля Камілгтона", "pos": Vector2i(25, 30), "type": TileTypes["DUNGEON"], "monsters": ["zombie", "shadow_assassin"]},
	],
	"points_of_interest": [
		{"name": "Храм Світла", "pos": Vector2i(25, 25), "type": TileTypes["CITY"], "quest": "blessing_of_light"},
		{"name": "Порт Камілгтона", "pos": Vector2i(20, 35), "type": TileTypes["CITY"], "event": "smuggler_encounter"},
	]
}

# Посилання на TileMap
@onready var tile_map: TileMap = $TileMap

# Посилання на гравця
@onready var player: CharacterBody2D = $Player

# Посилання на UI
@onready var ui: CanvasLayer = $UI
@onready var hud: Control = $UI/HUD
@onready var hp_label: Label = $UI/HUD/StatsPanel/HPLabel
@onready var mp_label: Label = $UI/HUD/StatsPanel/MPLabel
@onready var position_label: Label = $UI/HUD/StatsPanel/PositionLabel
@onready var dice_result_label: Label = $UI/HUD/DicePanel/DiceResultLabel


func _ready():
	# Генерируємо карту світу
	generate_world()
	
	# Налаштовуємо гравця
	if GameManager.current_player:
		player = GameManager.current_player
		player.global_position = cell_to_world(Vector2i(25, 25))
		player.current_cell = Vector2i(25, 25)
		update_ui()
	else:
		# Створюємо тимчасового гравця для тесту
		player.global_position = cell_to_world(Vector2i(25, 25))
		player.current_cell = Vector2i(25, 25)
	
	# Підписуємося на події гравця
	player.connect("player_moved", Callable(self, "_on_player_moved"))


## Генерація світу
func generate_world():
	# Заповнюємо карту травою (0)
	for x in range(MAP_SIZE.x):
		for y in range(MAP_SIZE.y):
			tile_map.set_cell(0, Vector2i(x, y), TileTypes["GRASS"])
	
	# Додаємо ліси (1) у Kingdom of Kerinmor
	for x in range(5, 15):
		for y in range(10, 20):
			if randf() > 0.3:
				tile_map.set_cell(0, Vector2i(x, y), TileTypes["FOREST"])
	
	# Додаємо гори (2) у Kingdom of Revenhold
	for x in range(35, 50):
		for y in range(0, 10):
			if randf() > 0.5:
				tile_map.set_cell(0, Vector2i(x, y), TileTypes["MOUNTAIN"])
	
	# Додаємо річки (3)
	for x in range(20, 30):
		tile_map.set_cell(0, Vector2i(x, 25), TileTypes["WATER"])
		tile_map.set_cell(0, Vector2i(x, 26), TileTypes["WATER"])
	
	# Додаємо дороги (4)
	for x in range(10, 25):
		tile_map.set_cell(0, Vector2i(x, 15), TileTypes["ROAD"])
	for y in range(15, 30):
		tile_map.set_cell(0, Vector2i(25, y), TileTypes["ROAD"])
	
	# Додаємо міста (5, 8)
	for city in locations["cities"]:
		tile_map.set_cell(0, Vector2i(city["pos"].x, city["pos"].y), city["type"])
	
	# Додаємо данжі (6, 7)
	for dungeon in locations["dungeons"]:
		tile_map.set_cell(0, Vector2i(dungeon["pos"].x, dungeon["pos"].y), dungeon["type"])
	
	# Додаємо точки інтересу
	for poi in locations["points_of_interest"]:
		tile_map.set_cell(0, Vector2i(poi["pos"].x, poi["pos"].y), poi["type"])


## Конвертація світові координати в клітинку
func world_to_cell(world_pos: Vector2) -> Vector2i:
	return tile_map.local_to_map(world_pos)


## Конвертація клітинки в світові координати
func cell_to_world(cell_pos: Vector2i) -> Vector2:
	return tile_map.map_to_local(cell_pos)


## Перевірка, чи клітинка прохідна
func is_cell_walkable(cell_pos: Vector2i) -> bool:
	var cell_id = tile_map.get_cell_source_id(0, cell_pos)
	# 0 = трава, 4 = дорога, 5 = місто, 6 = данж, 7 = печера, 8 = Камілгтон
	# 1 = ліс (прохідний, але з штрафом), 2 = гори (непрохідні), 3 = вода (непрохідна)
	return cell_id in [TileTypes["GRASS"], TileTypes["FOREST"], TileTypes["ROAD"], 
	                  TileTypes["CITY"], TileTypes["DUNGEON"], TileTypes["CAVE"], 
	                  TileTypes["CAMILGTON"]]


## Отримання типу місцевості
func get_cell_terrain(cell_pos: Vector2i) -> String:
	var cell_id = tile_map.get_cell_source_id(0, cell_pos)
	match cell_id:
		TileTypes["GRASS"]:
			return "grass"
		TileTypes["FOREST"]:
			return "forest"
		TileTypes["MOUNTAIN"]:
			return "mountain"
		TileTypes["WATER"]:
			return "water"
		TileTypes["ROAD"]:
			return "road"
		TileTypes["CITY"]:
			return "city"
		TileTypes["DUNGEON"]:
			return "dungeon"
		TileTypes["CAVE"]:
			return "cave"
		TileTypes["CAMILGTON"]:
			return "city"
		_:
			return "unknown"


## Обробка руху гравця
func _on_player_moved(new_cell: Vector2i):
	player.current_cell = new_cell
	update_ui()
	
	# Перевіряємо, чи гравець на клітинці з локацією
	for dungeon in locations["dungeons"]:
		if Vector2i(dungeon["pos"].x, dungeon["pos"].y) == new_cell:
			enter_dungeon(dungeon["name"])
			return
	
	for city in locations["cities"]:
		if Vector2i(city["pos"].x, city["pos"].y) == new_cell:
			enter_city(city["name"])
			return
	
	# Випадкова зустріч (10% шанс)
	if randf() < 0.1:
		random_encounter()


## Вхід до данжу
func enter_dungeon(dungeon_name: String):
	print("Вхід до данжу: ", dungeon_name)
	# Завантажуємо данж
	GameManager.load_dungeon(dungeon_name)


## Вхід до міста
func enter_city(city_name: String):
	print("Вхід до міста: ", city_name)
	# Завантажуємо місто
	GameManager.load_city(city_name)


## Випадкова зустріч
func random_encounter():
	var encounter_type = randi() % 4
	match encounter_type:
		0:
			print("Зустріч з монстрами!")
			start_combat(["cultist", "zombie"])
		1:
			print("Пастка!")
			if player:
				player.take_damage(DiceSystem.roll_d6())
		2:
			print("Зустріч з NPC!")
			# Додаємо діалог
		3:
			print("Знахідка!")
			if player:
				player.add_item({"name": "Зілля лікування", "type": "potion", "effect": "heal", "value": 10})


## Початок бою
func start_combat(enemies: Array):
	# Завантажуємо бій
	GameManager.load_combat(enemies)


## Обробка натискання кнопки "Кинути кубик"
func _on_roll_button_pressed():
	var roll = DiceSystem.roll_d6()
	dice_result_label.text = "Кубик d6: %d" % roll
	
	# Рухаємо гравця на випадкову відстань
	var direction = Vector2i(randi() % 3 - 1, randi() % 3 - 1)
	var target_cell = player.current_cell + direction * roll
	
	# Перевіряємо, чи клітинка прохідна
	if is_cell_walkable(target_cell):
		player.move_to_cell(target_cell)


## Обробка натискання кнопки "Рух"
func _on_move_button_pressed():
	# Рухаємо гравця на 1 клітинку в вибраному напрямку
	var target_cell = player.current_cell + Vector2i(1, 0)
	if is_cell_walkable(target_cell):
		player.move_to_cell(target_cell)


## Оновлення UI
func update_ui():
	if player:
		hp_label.text = "HP: %d/%d" % [player.get_meta("hp", 10), player.get_meta("max_hp", 10)]
		mp_label.text = "MP: %d/%d" % [player.get_meta("mp", 0), player.get_meta("max_mp", 0)]
		position_label.text = "Position: (%d, %d)" % [player.current_cell.x, player.current_cell.y]


func _process(delta):
	# Оновлюємо UI кожен кадр
	update_ui()
