extends Control
## CharacterCreation.gd - Екран створення персонажа

# Раси
var races: Array = ["Людина", "Ельф", "Дворф", "Орк", "Гном", "Піворк", "Тіфлінг"]

# Клас
var classes: Array = ["Воїн", "Маг", "Слідопит", "Клерик"]

# Характеристики
var stats: Dictionary = {
	"Сила": 0,
	"Спритність": 0,
	"Витривалість": 0,
	"Інтелект": 0,
	"Мудрість": 0,
	"Харизма": 0
}

# Бонуси рас
var race_bonuses: Dictionary = {
	"Людина": {"Сила": 1, "Спритність": 1, "Витривалість": 1, "Інтелект": 1, "Мудрість": 1, "Харизма": 1},
	"Ельф": {"Спритність": 2, "Інтелект": 1},
	"Дворф": {"Витривалість": 2, "Сила": 1},
	"Орк": {"Сила": 2, "Витривалість": 1},
	"Гном": {"Інтелект": 2, "Мудрість": 1},
	"Піворк": {"Сила": 1, "Спритність": 1, "Витривалість": 1},
	"Тіфлінг": {"Спритність": 1, "Харизма": 2}
}

# Посилання на UI елементи
@onready var name_input: LineEdit = $FormContainer/NameInput
@onready var race_selector: OptionButton = $FormContainer/RaceSelector
@onready var class_selector: OptionButton = $FormContainer/ClassSelector
@onready var stats_display: Label = $FormContainer/StatsDisplay


func _ready():
	# Заповнюємо вибір раси
	for race in races:
		race_selector.add_item(race)
	
	# Заповнюємо вибір класу
	for class_name in classes:
		class_selector.add_item(class_name)
	
	# Початкові кидки характеристик
	_roll_stats()


## Кидок характеристик
func _roll_stats():
	for stat in stats.keys():
		# Кидок 4d6, відкидаємо найнижчий
		var rolls = []
		for _i in range(4):
			rolls.append(DiceSystem.roll_d6())
		rolls.sort()
		rolls.remove_at(0)  # Видаляємо найнижчий
		stats[stat] = sum(rolls)
	
	# Додаємо бонуси раси
	var selected_race = race_selector.get_item_text(race_selector.selected)
	if race_bonuses.has(selected_race):
		for stat in race_bonuses[selected_race]:
			stats[stat] += race_bonuses[selected_race][stat]
	
	# Оновлюємо відображення
	_update_stats_display()


## Оновлення відображення характеристик
func _update_stats_display():
	var text = ""
	for stat in stats.keys():
		text += "%s: %d\n" % [stat, stats[stat]]
	stats_display.text = text


## Обробка натискання кнопки "Кинути кубики"
func _on_roll_button_pressed():
	_roll_stats()


## Обробка натискання кнопки "Підтвердити"
func _on_confirm_button_pressed():
	var character_name = name_input.text
	if character_name.is_empty():
		print("Будь ласка, введіть ім'я")
		return
	
	var selected_race = race_selector.get_item_text(race_selector.selected)
	var selected_class = class_selector.get_item_text(class_selector.selected)
	
	# Створюємо гравця залежно від класу
	var player_scene = null
	match selected_class:
		"Воїн":
			player_scene = preload("res://scenes/characters/fighter.tscn")
		"Маг":
			player_scene = preload("res://scenes/characters/mage.tscn")
		"Слідопит":
			player_scene = preload("res://scenes/characters/ranger.tscn")
		"Клерик":
			player_scene = preload("res://scenes/characters/cleric.tscn")
		_:
			player_scene = preload("res://scenes/characters/fighter.tscn")
	
	# Створюємо гравця
	var player = player_scene.instantiate()
	player.name = character_name
	player.race = selected_race
	player.class_name = selected_class
	
	# Встановлюємо характеристики
	for stat in stats:
		player.set_meta(stat.to_lower(), stats[stat])
	
	# Додаємо гравця до GameManager
	GameManager.add_player(player)
	
	# Завантажуємо світ
	get_tree().change_scene_to_file("res://scenes/world/overworld.tscn")


## Обробка натискання кнопки "Назад"
func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
