extends Node
## GameManager - Головний менеджер гри
## Керує станом гри, завантаженням сцен, гравцями тощо

# Посилання на поточного гравця
var current_player: Node2D

# Список усіх гравців (для кооперативу)
var players: Array = []

# Поточний стан гри
enum GameState { OVERWORLD, DUNGEON, COMBAT, CITY, MENU }
var current_state: GameState = GameState.MENU

# Поточна карта світу
var current_world_map: Node2D

# Поточний данж
var current_dungeon: Node2D

# Поточний бій
var current_combat: Node2D


func _ready():
	# Реєструємо сигнали
	process_mode = Node.PROCESS_MODE_ALWAYS


## Зміна стану гри
func change_state(new_state: GameState):
	current_state = new_state
	emit_signal("game_state_changed", new_state)


## Додавання гравця
func add_player(player_node: Node2D):
	players.append(player_node)
	current_player = player_node
	emit_signal("player_added", player_node)


## Видалення гравця
func remove_player(player_node: Node2D):
	players.erase(player_node)
	if current_player == player_node:
		if players.size() > 0:
			current_player = players[0]
		else:
			current_player = null
	emit_signal("player_removed", player_node)


## Завантаження світу
func load_world():
	change_state(GameState.OVERWORLD)
	var world_scene = preload("res://scenes/world/overworld.tscn")
	current_world_map = world_scene.instantiate()
	get_tree().root.add_child(current_world_map)


## Завантаження данжу
func load_dungeon(dungeon_name: String):
	change_state(GameState.DUNGEON)
	# Знищуємо поточний світ, якщо він існує
	if current_world_map:
		current_world_map.queue_free()
	current_world_map = null
	
	# Завантажуємо данж
	var dungeon_scene = preload("res://scenes/dungeons/dungeon.tscn")
	current_dungeon = dungeon_scene.instantiate()
	current_dungeon.set_meta("dungeon_name", dungeon_name)
	get_tree().root.add_child(current_dungeon)


## Завантаження бою
func load_combat(enemies: Array):
	change_state(GameState.COMBAT)
	# Знищуємо поточний данж, якщо він існує
	if current_dungeon:
		current_dungeon.queue_free()
	current_dungeon = null
	
	# Завантажуємо бій
	var combat_scene = preload("res://scenes/combat.tscn")
	current_combat = combat_scene.instantiate()
	current_combat.set_meta("enemies", enemies)
	get_tree().root.add_child(current_combat)


## Повернення до світу
func return_to_world():
	change_state(GameState.OVERWORLD)
	# Знищуємо поточний бій або данж
	if current_combat:
		current_combat.queue_free()
	current_combat = null
	if current_dungeon:
		current_dungeon.queue_free()
	current_dungeon = null
	
	# Завантажуємо світ
	load_world()


## Завантаження міста
func load_city(city_name: String):
	change_state(GameState.CITY)
	# Знищуємо поточний світ
	if current_world_map:
		current_world_map.queue_free()
	current_world_map = null
	
	# Завантажуємо місто
	var city_scene = preload("res://scenes/world/city.tscn")
	var city = city_scene.instantiate()
	city.set_meta("city_name", city_name)
	get_tree().root.add_child(city)


## Повернення до меню
func return_to_menu():
	change_state(GameState.MENU)
	# Знищуємо всі поточні сцени
	for child in get_tree().root.get_children():
		if child != self:
			child.queue_free()
	
	# Завантажуємо головне меню
	var menu_scene = preload("res://scenes/main.tscn")
	get_tree().root.add_child(menu_scene)


## Сигнали
signal game_state_changed(new_state: GameState)
signal player_added(player: Node2D)
signal player_removed(player: Node2D)
