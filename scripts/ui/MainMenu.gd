extends Control

@onready var new_game_button: Button = $ButtonContainer/NewGameButton
@onready var load_game_button: Button = $ButtonContainer/LoadGameButton
@onready var quit_button: Button = $ButtonContainer/QuitButton

func _ready():
	new_game_button.pressed.connect(_on_new_game_pressed)
	load_game_button.pressed.connect(_on_load_game_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://scenes/world/overworld.tscn")

func _on_load_game_pressed():
	# Load game functionality would go here
	GameManager.load_game()
	get_tree().change_scene_to_file("res://scenes/world/overworld.tscn")

func _on_quit_pressed():
	get_tree().quit()
