extends Control

@onready var new_game_button: Button = $ButtonContainer/NewGameButton
@onready var load_game_button: Button = $ButtonContainer/LoadGameButton
@onready var quit_button: Button = $ButtonContainer/QuitButton

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	new_game_button.pressed.connect(_on_new_game)
	load_game_button.pressed.connect(_on_load_game)
	quit_button.pressed.connect(_on_quit)

func _on_new_game():
	get_tree().change_scene_to_file("res://scenes/world/character_creation.tscn")

func _on_load_game():
	get_tree().change_scene_to_file("res://scenes/world/overworld.tscn")

func _on_quit():
	get_tree().quit()
