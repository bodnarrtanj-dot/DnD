extends Node

var current_player: CharacterBody2D = null
var current_scene: String = ""
var game_state: Dictionary = {}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func load_overworld():
	current_scene = "overworld"
	get_tree().change_scene_to_file("res://scenes/world/overworld.tscn")

func load_dungeon(dungeon_name: String):
	current_scene = "dungeon"
	GameManager.current_dungeon = dungeon_name
	get_tree().change_scene_to_file("res://scenes/dungeons/dungeon.tscn")

func load_combat(monsters: Array):
	current_scene = "combat"
	GameManager.current_monsters = monsters
	get_tree().change_scene_to_file("res://scenes/combat/combat.tscn")

func load_city(city_name: String):
	current_scene = "city"
	GameManager.current_city = city_name
	get_tree().change_scene_to_file("res://scenes/city/city.tscn")

func load_main_menu():
	current_scene = "main_menu"
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func save_game():
	# Save game state to file
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	if save_file:
		save_file.store_string(JSON.stringify(game_state))
		save_file.close()

func load_game():
	# Load game state from file
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	if save_file:
		var json = save_file.get_as_text()
		game_state = JSON.parse_string(json)
		save_file.close()
		return true
	return false
