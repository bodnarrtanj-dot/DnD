extends Node2D
## City.gd - Клас міста

# Назва міста
var city_name: String = "Камілгтон"

# Посилання на UI
@onready var ui: CanvasLayer = $UI
@onready var title_label: Label = $UI/HUD/TitleLabel
@onready var hp_label: Label = $UI/HUD/StatsPanel/HPLabel

# Дані про локації у місті
var locations: Dictionary = {
	"tavern": {
		"name": "Таверна 'Чорний Крук'",
		"description": "Місце для відпочинку та збору інформації.",
		"quests": ["cult_investigation"]
	},
	"temple": {
		"name": "Храм Світла",
		"description": "Святе місце, де можна отримати благословення.",
		"services": ["blessing", "healing"]
	},
	"shop": {
		"name": "Крама",
		"description": "Місце для покупки зброї та предметів.",
		"items": [
			{"name": "Зілля лікування", "price": 50, "type": "potion"},
			{"name": "Меч +1", "price": 200, "type": "weapon"},
			{"name": "Шкіряна броня", "price": 100, "type": "armor"}
		]
	}
}


func _ready():
	# Отримуємо ім'я міста з метаданих
	city_name = get_meta("city_name", "Камілгтон")
	title_label.text = "Місто: %s" % city_name
	
	# Оновлюємо UI
	update_ui()


## Оновлення UI
func update_ui():
	if GameManager.current_player:
		hp_label.text = "HP: %d/%d" % [GameManager.current_player.hp, GameManager.current_player.max_hp]


## Обробка натискання кнопки "Таверна"
func _on_tavern_button_pressed():
	log_message("Ви заходите до таверни '%s'" % locations["tavern"]["name"])
	# Додаємо квест, якщо він ще не доданий
	if not QuestSystem.get_quest("cult_investigation"):
		var quest = {
			"id": "cult_investigation",
			"name": "Розслідування культу Каплоса",
			"description": "Знайдіть табір культистів у лісі Kerinmor та дізнайтеся про їхні плани.",
			"objectives": [
				{"type": "explore", "location": "Табір культистів", "completed": false},
				{"type": "find", "item": "Щоденник адепта", "completed": false}
			],
			"reward_xp": 200,
			"reward_gold": 100,
			"reward_item": "Карта до Камілгтона"
		}
		QuestSystem.add_quest(quest)
		log_message("Ви отримали новий квест: %s" % quest["name"])


## Обробка натискання кнопки "Храм"
func _on_temple_button_pressed():
	log_message("Ви заходите до %s" % locations["temple"]["name"])
	# Отримуємо благословення
	if GameManager.current_player:
		GameManager.current_player.set_meta("blessed", true)
		log_message("Ви отримали благословення! +2 до рятувальних кидків проти темряви.")


## Обробка натискання кнопки "Крама"
func _on_shop_button_pressed():
	log_message("Ви заходите до крамниці")
	# Показуємо список предметів
	for item in locations["shop"]["items"]:
		log_message("-%s (%d золотих)" % [item["name"], item["price"]])


## Обробка натискання кнопки "Вийти з міста"
func _on_exit_button_pressed():
	# Повертаємося до світу
	GameManager.return_to_world()


## Додавання повідомлення до логу (тимчасово)
func log_message(message: String):
	print(message)


func _process(delta):
	update_ui()
