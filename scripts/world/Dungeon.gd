extends Node2D
## Dungeon.gd - Клас данжу

# Розмір данжу (клітинок)
const DUNGEON_SIZE: Vector2i = Vector2i(20, 20)

# Розмір клітинки (пікселів)
const CELL_SIZE: Vector2i = Vector2i(16, 16)

# Типи клітинок
@onready var TileTypes = {
	"WALL": 0,
	"FLOOR": 1,
	"TRAP": 2,
	"TREASURE": 3,
	"DOOR": 4,
	"STAIRS": 5
}

# Дані про данж
var dungeon_data: Dictionary = {
	"name": "Табір культистів",
	"monsters": ["cultist", "adept"],
	"treasures": ["Scroll of Cult Lore"],
	"traps": ["otruyni_shypy"]
}

# Посилання на TileMap
@onready var tile_map: TileMap = $TileMap

# Посилання на гравця
@onready var player: CharacterBody2D = $Player

# Посилання на UI
@onready var ui: CanvasLayer = $UI
@onready var hud: Control = $UI/HUD
@onready var hp_label: Label = $UI/HUD/StatsPanel/HPLabel

# Список монстрів у данжі
var enemies: Array = []

# Список скарбів
var treasures: Array = []

# Список пасток
var traps: Array = []

# Чи данж уже генерований
var is_generated: bool = false


func _ready():
	# Отримуємо ім'я данжу з метаданих
	var dungeon_name = get_meta("dungeon_name", "Табір культистів")
	
	# Завантажуємо дані про данж
	load_dungeon_data(dungeon_name)
	
	# Генерируємо данж
	generate_dungeon()
	
	# Налаштовуємо гравця
	if GameManager.current_player:
		player = GameManager.current_player
		player.global_position = cell_to_world(Vector2i(10, 10))
		player.current_cell = Vector2i(10, 10)
		update_ui()
	
	# Підписуємося на події гравця
	player.connect("player_moved", Callable(self, "_on_player_moved"))


## Завантаження даних про данж
func load_dungeon_data(dungeon_name: String):
	match dungeon_name:
		"Табір культистів":
			dungeon_data = {
				"name": "Табір культистів",
				"monsters": ["cultist", "adept"],
				"treasures": ["Scroll of Cult Lore"],
				"traps": ["otruyni_shypy"],
				"layout": [
					[1, 1, 1, 1, 1, 1, 1],
					[1, 0, 0, 0, 1, 0, 1],
					[1, 0, 2, 3, 2, 0, 1],
					[1, 0, 0, 0, 0, 0, 1],
					[1, 1, 1, 0, 1, 1, 1],
					[1, 0, 0, 0, 0, 0, 1],
					[1, 0, 1, 0, 1, 0, 1],
					[1, 1, 1, 1, 1, 1, 1]
				]
			}
		"Печера Каплоса":
			dungeon_data = {
				"name": "Печера Каплоса",
				"monsters": ["necromancer", "shadow_assassin", "cult_leader"],
				"treasures": ["Amuletof Kaplos"],
				"traps": ["magic_barrier"],
				"layout": [
					[0, 0, 0, 0, 0],
					[0, 1, 1, 1, 0],
					[0, 1, 1, 1, 0],
					[0, 1, 1, 1, 0],
					[0, 0, 0, 0, 0]
				]
			}
		"Підземелля Камілгтона":
			dungeon_data = {
				"name": "Підземелля Камілгтона",
				"monsters": ["zombie", "shadow_assassin"],
				"treasures": ["Key to Cave of Kaplos"],
				"traps": ["magichna_setka"],
				"layout": [
					[0, 0, 0, 0, 0, 0, 0],
					[0, 1, 0, 0, 0, 1, 0],
					[0, 1, 0, 1, 0, 1, 0],
					[0, 1, 0, 0, 0, 1, 0],
					[0, 0, 0, 0, 0, 0, 0]
				]
			}
		_:
			dungeon_data = {
				"name": "Табір культистів",
				"monsters": ["cultist", "adept"],
				"treasures": ["Scroll of Cult Lore"],
				"traps": ["otruyni_shypy"],
				"layout": [
					[1, 1, 1, 1, 1, 1, 1],
					[1, 0, 0, 0, 1, 0, 1],
					[1, 0, 2, 3, 2, 0, 1],
					[1, 0, 0, 0, 0, 0, 1],
					[1, 1, 1, 0, 1, 1, 1],
					[1, 0, 0, 0, 0, 0, 1],
					[1, 0, 1, 0, 1, 0, 1],
					[1, 1, 1, 1, 1, 1, 1]
				]
			}


## Генерація данжу
func generate_dungeon():
	if is_generated:
		return
	
	is_generated = true
	
	# Якщо є заздалегідь визначений layout, використовуємо його
	if dungeon_data.has("layout"):
		for y in range(dungeon_data["layout"].size()):
			for x in range(dungeon_data["layout"][y].size()):
				var tile_type = dungeon_data["layout"][y][x]
				tile_map.set_cell(0, Vector2i(x, y), tile_type)
	else:
		# Генерація випадкового данжу
		generate_random_dungeon()
	
	# Додаємо гравця до центру данжу
	player.global_position = cell_to_world(Vector2i(DUNGEON_SIZE.x / 2, DUNGEON_SIZE.y / 2))
	player.current_cell = Vector2i(DUNGEON_SIZE.x / 2, DUNGEON_SIZE.y / 2)
	
	# Додаємо монстрів
	spawn_enemies()
	
	# Додаємо скарби
	spawn_treasures()
	
	# Додаємо пастки
	spawn_traps()


## Генерація випадкового данжу
func generate_random_dungeon():
	# Простий алгоритм генерації
	for x in range(DUNGEON_SIZE.x):
		for y in range(DUNGEON_SIZE.y):
			# Краї данжу - стіни
			if x == 0 or x == DUNGEON_SIZE.x - 1 or y == 0 or y == DUNGEON_SIZE.y - 1:
				tile_map.set_cell(0, Vector2i(x, y), TileTypes["WALL"])
			else:
				# Випадково визначаємо тип клітинки
				var rand_val = randf()
				if rand_val < 0.7:
					tile_map.set_cell(0, Vector2i(x, y), TileTypes["FLOOR"])
				elif rand_val < 0.8:
					tile_map.set_cell(0, Vector2i(x, y), TileTypes["WALL"])
				elif rand_val < 0.85:
					tile_map.set_cell(0, Vector2i(x, y), TileTypes["TRAP"])
				else:
					tile_map.set_cell(0, Vector2i(x, y), TileTypes["TREASURE"])


## Додавання монстрів
func spawn_enemies():
	for monster_type in dungeon_data.get("monsters", []):
		# Шукаємо вільну клітинку для монстра
		var spawn_pos = find_empty_cell()
		if spawn_pos != null:
			var monster_scene = null
			match monster_type:
				"cultist":
					monster_scene = preload("res://scenes/entities/cultist.tscn")
				"adept":
					monster_scene = preload("res://scenes/entities/adept.tscn")
				"zombie":
					monster_scene = preload("res://scenes/entities/zombie.tscn")
				"shadow_assassin":
					monster_scene = preload("res://scenes/entities/shadow_assassin.tscn")
				"necromancer":
					monster_scene = preload("res://scenes/entities/necromancer.tscn")
				"cult_leader":
					monster_scene = preload("res://scenes/entities/cult_leader.tscn")
				_:
					monster_scene = preload("res://scenes/entities/cultist.tscn")
			
			if monster_scene:
				var monster = monster_scene.instantiate()
				monster.global_position = cell_to_world(spawn_pos)
				monster.current_cell = spawn_pos
				add_child(monster)
				enemies.append(monster)


## Додавання скарбів
func spawn_treasures():
	for treasure_name in dungeon_data.get("treasures", []):
		var spawn_pos = find_empty_cell()
		if spawn_pos != null:
			# В реальному проєкті тут буде створений об'єкт скарбу
			print("Скарб '%s' додано до клітинки %s" % [treasure_name, spawn_pos])
			treasures.append({"name": treasure_name, "position": spawn_pos})


## Додавання пасток
func spawn_traps():
	for trap_type in dungeon_data.get("traps", []):
		var spawn_pos = find_empty_cell()
		if spawn_pos != null:
			# В реальному проєкті тут буде створений об'єкт пастки
			print("Пастка '%s' додано до клітинки %s" % [trap_type, spawn_pos])
			traps.append({"type": trap_type, "position": spawn_pos})


## Пошук вільної клітинки
func find_empty_cell() -> Vector2i:
	for x in range(DUNGEON_SIZE.x):
		for y in range(DUNGEON_SIZE.y):
			var cell_pos = Vector2i(x, y)
			if tile_map.get_cell_source_id(0, cell_pos) == TileTypes["FLOOR"]:
				# Перевіряємо, чи клітинка не зайнята
				var occupied = false
				for enemy in enemies:
					if enemy.current_cell == cell_pos:
						occupied = true
						break
				if not occupied:
					return cell_pos
	return null


## Конвертація світові координати в клітинку
func world_to_cell(world_pos: Vector2) -> Vector2i:
	return tile_map.local_to_map(world_pos)


## Конвертація клітинки в світові координати
func cell_to_world(cell_pos: Vector2i) -> Vector2:
	return tile_map.map_to_local(cell_pos)


## Перевірка, чи клітинка прохідна
func is_cell_walkable(cell_pos: Vector2i) -> bool:
	var cell_id = tile_map.get_cell_source_id(0, cell_pos)
	return cell_id in [TileTypes["FLOOR"], TileTypes["TREASURE"], TileTypes["DOOR"], TileTypes["STAIRS"]]


## Обробка руху гравця
func _on_player_moved(new_cell: Vector2i):
	player.current_cell = new_cell
	update_ui()
	
	# Перевіряємо, чи гравець на клітинці з монстром
	for enemy in enemies:
		if enemy.current_cell == new_cell:
			start_combat([enemy])
			return
	
	# Перевіряємо, чи гравець на клітинці з пасткою
	for trap in traps:
		if trap["position"] == new_cell:
			trigger_trap(trap)
			return
	
	# Перевіряємо, чи гравець на клітинці зі скарбом
	for treasure in treasures:
		if treasure["position"] == new_cell:
			collect_treasure(treasure)
			return


## Початок бою
func start_combat(enemy_list: Array):
	GameManager.load_combat(enemy_list)


## Активація пастки
func trigger_trap(trap: Dictionary):
	match trap["type"]:
		"otruyni_shypy":
			print("Пастка спрацювала! Отрута!")
			player.take_damage(DiceSystem.roll_d6())
		"magichna_setka":
			print("Пастка спрацювала! Магічна сітка!")
			# Гравця утримує на місці
			player.current_cell = trap["position"]
			player.global_position = cell_to_world(trap["position"])
		"magic_barrier":
			print("Магічний бар'єр! Потрібно кидок Мудрості!")
			var dc = 18
			var roll = DiceSystem.roll_d20() + player.wisdom_modifier
			if roll >= dc:
				print("Бар'єр знято!")
			else:
				print("Бар'єр не знято!")


## Збір скарбу
func collect_treasure(treasure: Dictionary):
	print("Знайдено скарб: %s" % treasure["name"])
	player.add_item({"name": treasure["name"], "type": "treasure"})
	# Видаляємо скарб зі списку
	for i in range(treasures.size()):
		if treasures[i]["position"] == treasure["position"]:
			treasures.erase(treasures[i])
			break


## Обробка натискання кнопки "Рух"
func _on_move_button_pressed():
	# Рухаємо гравця на 1 клітинку в вибраному напрямку
	var target_cell = player.current_cell + Vector2i(1, 0)
	if is_cell_walkable(target_cell):
		player.move_to_cell(target_cell)


## Обробка натискання кнопки "Атака"
func _on_attack_button_pressed():
	# Шукаємо найближчого ворога
	var closest_enemy = null
	var min_distance = INF
	
	for enemy in enemies:
		var distance = (enemy.global_position - player.global_position).length()
		if distance < min_distance:
			min_distance = distance
			closest_enemy = enemy
	
	if closest_enemy:
		player.attack(closest_enemy)


## Обробка натискання кнопки "Вийти з данжу"
func _on_exit_button_pressed():
	# Повертаємося до світу
	GameManager.return_to_world()


## Оновлення UI
func update_ui():
	if player:
		hp_label.text = "HP: %d/%d" % [player.hp, player.max_hp]


func _process(delta):
	# Оновлюємо UI кожен кадр
	update_ui()
