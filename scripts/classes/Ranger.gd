extends Player
## Ranger.gd - Клас Слідопит

# Улюблений тип ворога
var favored_enemy: String = "Культисти"

# Улюблена місцевість
var favored_terrain: String = "Ліс"

# Тварина-компаньйон
var animal_companion: Dictionary = null


func _ready():
	# Встановлюємо базові характеристики для Слідопита
	class_name = "Слідопит"
	dexterity = 16
	wisdom = 14
	constitution = 14
	max_hp = 8 + constitution_modifier
	hp = max_hp
	actions_per_turn = 1
	
	# Здібності
	abilities = [
		{"name": "Улюблений ворог", "description": "+2 до урону проти " + favored_enemy, "level": 1, "effect": "favored_enemy"},
		{"name": "Улюблена місцевість", "description": "+2 до навичок у " + favored_terrain, "level": 1, "effect": "favored_terrain"},
		{"name": "Слідопитові тварини", "description": "Можна прикликати тварину (вовк, ведмідь)", "level": 3, "effect": "animal_companion"},
		{"name": "Стрілянина", "description": "+1 до урону з лука на кожні 10 клітинок відстані", "level": 5, "effect": "ranged_damage"},
		{"name": "Маскування", "description": "+4 до класу броні, якщо не рухається", "level": 7, "effect": "camouflage"},
		{"name": "Мисливський інстинкт", "description": "Автоматично виявляє прихованих ворогів", "level": 10, "effect": "detect_hidden"}
	]
	
	# Навички
	skills = {
		"Survival": wisdom_modifier + 2,
		"Perception": wisdom_modifier + 2,
		"Athletics": strength_modifier + 1,
		"Stealth": dexterity_modifier + 2
	}
	
	# Обладнання
	equipment["weapon"] = {"name": "Лук", "type": "ranged", "damage_dice": "1d8", "attack_bonus": 2, "range": 20}
	equipment["armor"] = {"name": "Шкіряна броня", "ac_bonus": 2}
	
	# Оновлюємо UI
	update_ui()


## Прикликання тварини-компаньйона
func summon_animal_companion(animal_type: String):
	if not has_ability("Слідопитові тварини"):
		return false
	
	match animal_type:
		"вовк":
			animal_companion = {
				"name": "Вовк",
				"type": "wolf",
				"hp": 20,
				"ac": 13,
				"attacks": [{"name": "Укус", "damage": "1d6 + 2", "hit_bonus": 4}],
				"abilities": ["Pack Tactics"]
			}
		"ведмідь":
			animal_companion = {
				"name": "Ведмідь",
				"type": "bear",
				"hp": 40,
				"ac": 11,
				"attacks": [{"name": "Кігті", "damage": "2d6 + 3", "hit_bonus": 5}],
				"abilities": ["Multiattack"]
			}
		_:
			return false
	
	emit_signal("animal_summoned", animal_companion)
	return true


## Отримання бонусу до урону проти улюбленого ворога
func get_favored_enemy_bonus(target: Node2D) -> int:
	if target.get_meta("type", "") == favored_enemy.to_lower():
		return 2
	return 0


## Отримання бонусу до навичок у улюбленій місцевості
func get_favored_terrain_bonus(terrain: String) -> int:
	if terrain == favored_terrain:
		return 2
	return 0


## Перевірка наявності здібності
func has_ability(ability_name: String) -> bool:
	for ability in abilities:
		if ability["name"] == ability_name:
			return true
	return false


## Сигнали
signal animal_summoned(companion: Dictionary)
