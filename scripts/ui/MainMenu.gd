extends Control
## MainMenu.gd - Головне меню гри

# Кнопки меню
@onready var new_game_button: Button = $ButtonContainer/NewGameButton
@onready var load_game_button: Button = $ButtonContainer/LoadGameButton
@onready var settings_button: Button = $ButtonContainer/SettingsButton
@onready var quit_button: Button = $ButtonContainer/QuitButton


func _ready():
	# Приховуємо курсор миші (не обов'язково)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


## Нова гра
func _on_new_game_pressed():
	# Завантажуємо екран створення персонажа
	get_tree().change_scene_to_file("res://scenes/world/character_creation.tscn")


## Завантажити гру (поки що не реалізовано)
func _on_load_game_pressed():
	# Поки що просто завантажуємо світ
	get_tree().change_scene_to_file("res://scenes/world/overworld.tscn")


## Налаштування (поки що не реалізовано)
func _on_settings_pressed():
	print("Налаштування - ще не реалізовано")


## Вихід з гри
func _on_quit_pressed():
	get_tree().quit()
