extends Player
## Fighter.gd - Клас Воїн

# Додаткові характеристики для Воїна
var action_surge_available: bool = true


func _ready():
	# Встановлюємо базові характеристики для Воїна
	class_name = "Воїн"
	strength = 16
	dexterity = 14
	constitution = 16
	max_hp = 10 + constitution_modifier
	hp = max_hp
	actions_per_turn = 1
	
	# Здібності
	abilities = [
		{"name": "Бойовий стиль", "description": "+1 до урону всіма видами зброї", "level": 1, "effect": "attack_bonus"},
		{"name": "Другий шанс", "description": "1 раз за бій можна перекинути невдалий кидок атаки", "level": 3, "effect": "reroll_attack"},
		{"name": "Потужний удар", "description": "1 раз за бій може подвоїти шкоду від атаки", "level": 5, "effect": "double_damage"},
		{"name": "Непереможний", "description": "+2 до рятувальних кидків Витривалості", "level": 7, "effect": "constitution_save"},
		{"name": "Лідер", "description": "Сусіди отримують +1 до класу броні", "level": 10, "effect": "aura_ac"},
		{"name": "Смертельний удар", "description": "Критичні влучення заподіюють потрійну шкоду", "level": 15, "effect": "triple_critical"}
	]
	
	# Навички
	skills = {
		"Athletics": strength_modifier + 2,
		"Intimidation": charisma_modifier + 1
	}
	
	# Обладнання
	equipment["weapon"] = {"name": "Меч", "type": "melee", "damage_dice": "1d8", "attack_bonus": 3}
	equipment["armor"] = {"name": "Пластинчаста броня", "ac_bonus": 4}
	equipment["shield"] = {"name": "Стальний щит", "ac_bonus": 2}
	
	# Оновлюємо UI
	update_ui()


## Використання здібності "Другий шанс"
func use_second_chance():
	if not has_ability("Другий шанс"):
		return false
	
	if action_surge_available:
		action_surge_available = false
		return true
	return false


## Використання здібності "Потужний удар"
func use_powerful_strike():
	if not has_ability("Потужний удар"):
		return false
	
	if action_surge_available:
		action_surge_available = false
		return true
	return false


## Перевірка наявності здібності
func has_ability(ability_name: String) -> bool:
	for ability in abilities:
		if ability["name"] == ability_name:
			return true
	return false


## Отримання бонусу до атаки
func get_attack_bonus() -> int:
	var base_bonus = equipment["weapon"].get("attack_bonus", 0) + strength_modifier
	if has_ability("Бойовий стиль"):
		base_bonus += 1
	return base_bonus
