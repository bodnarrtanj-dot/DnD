extends CharacterBody2D
class_name Player
## Player.gd - Клас гравця

# Базові характеристики
var name: String = "Авантюрист"
var race: String = "Людина"
var class_name: String = "Воїн"
var level: int = 1
var xp: int = 0
var xp_to_next_level: int = 100

# Характеристики D&D
var strength: int = 10
var dexterity: int = 10
var constitution: int = 10
var intelligence: int = 10
var wisdom: int = 10
var charisma: int = 10

# Обчислювані модифікатори
var strength_modifier: int:
	get:
		return _calculate_modifier(strength)
	
var dexterity_modifier: int:
	get:
		return _calculate_modifier(dexterity)
	
var constitution_modifier: int:
	get:
		return _calculate_modifier(constitution)
	
var intelligence_modifier: int:
	get:
		return _calculate_modifier(intelligence)
	
var wisdom_modifier: int:
	get:
		return _calculate_modifier(wisdom)
	
var charisma_modifier: int:
	get:
		return _calculate_modifier(charisma)

# HP та MP
var max_hp: int = 10
var hp: int:
	get:
		return _hp
	set(value):
		_hp = value
		if _hp <= 0:
			_hp = 0
			emit_signal("defeated", self)
		elif _hp > max_hp:
			_hp = max_hp

var _hp: int = 10

var max_mp: int = 0
var mp: int = 0

# Клас броні (AC)
var ac: int:
	get:
		# Базовий AC = 10 + DEX + броня
		var base_ac = 10 + dexterity_modifier
		# Додаємо бонус від броні
		if equipment.has("armor"):
			base_ac += equipment["armor"].get("ac_bonus", 0)
		# Додаємо бонус від щита
		if equipment.has("shield"):
			base_ac += equipment["shield"].get("ac_bonus", 0)
		return base_ac

# Швидкість руху (клітинок за хід)
var speed: int = 1

# Кількість дій за хід
var actions_per_turn: int = 1

# Обладнання
var equipment: Dictionary = {
	"weapon": null,
	"armor": null,
	"shield": null,
	"helmet": null,
	"boots": null,
	"ring": null,
	"amulet": null
}

# Інвентар
var inventory: Array = []

# Здібності класу
var abilities: Array = []

# Навички
var skills: Dictionary = {}

# Поточна позиція на карті
var current_cell: Vector2i = Vector2i(0, 0)

# Чи зараз хід гравця
var is_turn: bool = false


func _ready():
	# Визначаємо базові характеристики залежно від класу
	_setup_class_stats()
	# Оновлюємо UI
	update_ui()


## Налаштування характеристик залежно від класу
func _setup_class_stats():
	match class_name:
		"Воїн":
			strength = 16
			dexterity = 14
			constitution = 16
			max_hp = 10 + constitution_modifier
			hp = max_hp
			actions_per_turn = 1
			abilities = [
				{"name": "Бойовий стиль", "description": "+1 до урону всіма видами зброї", "level": 1},
				{"name": "Другий шанс", "description": "1 раз за бій можна перекинути невдалий кидок атаки", "level": 3}
			]
			skills = {
				"Athletics": strength_modifier + 2,
				"Intimidation": charisma_modifier
			}
			# Стандартна зброя
			equipment["weapon"] = {"name": "Меч", "type": "melee", "damage_dice": "1d6", "attack_bonus": 2}
			equipment["armor"] = {"name": "Ланцюгова броня", "ac_bonus": 3}
			equipment["shield"] = {"name": "Дерев'яний щит", "ac_bonus": 2}
		
		"Маг":
			intelligence = 16
			dexterity = 14
			constitution = 10
			max_hp = 6 + constitution_modifier
			hp = max_hp
			max_mp = 10 + intelligence_modifier
			mp = max_mp
			actions_per_turn = 1
			abilities = [
				{"name": "Магічна чутливість", "description": "+1 до виявлення магічних предметів", "level": 1},
				{"name": "Швидке чаклування", "description": "1 раз за бій може використовувати заклинання без витрат MP", "level": 3}
			]
			skills = {
				"Arcana": intelligence_modifier + 2,
				"Perception": wisdom_modifier
			}
			# Стандартна зброя
			equipment["weapon"] = {"name": "Палиця", "type": "melee", "damage_dice": "1d4", "attack_bonus": 0}
		
		"Слідопит":
			dexterity = 16
			wisdom = 14
			constitution = 14
			max_hp = 8 + constitution_modifier
			hp = max_hp
			actions_per_turn = 1
			abilities = [
				{"name": "Улюблений ворог", "description": "+2 до урону проти обраного типу ворогів", "level": 1},
				{"name": "Стрілянина", "description": "+1 до урону з лука на кожні 10 клітинок відстані", "level": 5}
			]
			skills = {
				"Survival": wisdom_modifier + 2,
				"Perception": wisdom_modifier + 2,
				"Athletics": strength_modifier
			}
			# Стандартна зброя
			equipment["weapon"] = {"name": "Лук", "type": "ranged", "damage_dice": "1d8", "attack_bonus": 2}
			equipment["armor"] = {"name": "Шкіряна броня", "ac_bonus": 2}
		
		"Клерик":
			wisdom = 16
			constitution = 14
			charisma = 12
			max_hp = 8 + constitution_modifier
			hp = max_hp
			max_mp = 10 + wisdom_modifier
			mp = max_mp
			actions_per_turn = 1
			abilities = [
				{"name": "Божественний домен", "description": "Вибір домену (Світло, Темрява, Вогонь, Лікування)", "level": 1},
				{"name": "Свята символія", "description": "1 раз за день може використовувати заклинання 1 рівня без витрат MP", "level": 1}
			]
			skills = {
				"Medicine": wisdom_modifier + 2,
				"Religion": intelligence_modifier,
				"Perception": wisdom_modifier
			}
			# Стандартна зброя
			equipment["weapon"] = {"name": "Буздиган", "type": "melee", "damage_dice": "1d6", "attack_bonus": 1}
			equipment["armor"] = {"name": "Ланцюгова броня", "ac_bonus": 3}
			equipment["shield"] = {"name": "Дерев'яний щит", "ac_bonus": 2}


## Обчислення модифікатора характеристики
func _calculate_modifier(value: int) -> int:
	return floor((value - 10) / 2.0)


## Рух гравця по сітці
func move_to_cell(target_cell: Vector2i):
	# Перевіряємо, чи клітинка прохідна
	var overworld = get_parent()
	if overworld and overworld.is_cell_walkable(target_cell):
		current_cell = target_cell
		global_position = overworld.cell_to_world(current_cell)
		emit_signal("player_moved", current_cell)


## Атака гравця
func attack(target: Node2D) -> bool:
	if not is_turn:
		return false
	
	var weapon = equipment.get("weapon", null)
	if weapon == null:
		return false
	
	# Кидок атаки
	var attack_bonus = weapon.get("attack_bonus", 0)
	if weapon.get("type", "melee") == "melee":
		attack_bonus += strength_modifier
	else:
		attack_bonus += dexterity_modifier
	
	var attack_roll = DiceSystem.roll_d20() + attack_bonus
	
	# Отримуємо AC цілі
	var target_ac = target.get_meta("ac", 10)
	
	# Перевіряємо влучний
	var is_hit = attack_roll >= target_ac
	var is_critical = DiceSystem.is_critical_roll(attack_roll, "d20")
	
	# Визначаємо шкоду
	var damage = 0
	if is_hit:
		var damage_dice = weapon.get("damage_dice", "1d6")
		var damage_roll = _parse_damage_dice(damage_dice)
		var damage_mod = strength_modifier if weapon.get("type", "melee") == "melee" else dexterity_modifier
		damage = damage_roll + damage_mod
		
		# Критичний влучний - подвійна шкода
		if is_critical == 1:
			damage *= 2
			emit_signal("critical_hit", self, target, damage)
		
		# Застосовуємо шкоду
		target.take_damage(damage)
		
		emit_signal("attack_result", self, target, true, damage, is_critical)
	else:
		emit_signal("attack_result", self, target, false, 0, 0)
	
	return is_hit


## Отримання шкоди
func take_damage(amount: int):
	hp -= amount


## Додавання досвіду
func add_xp(amount: int):
	xp += amount
	# Перевіряємо, чи можна підняти рівень
	if xp >= xp_to_next_level:
		level_up()


## Підвищення рівня
func level_up():
	level += 1
	xp -= xp_to_next_level
	xp_to_next_level = int(xp_to_next_level * 1.5)
	
	# Збільшуємо HP
	max_hp += DiceSystem.roll_dice(6) + constitution_modifier
	hp = max_hp
	
	# Збільшуємо MP (для магічних класів)
	if class_name == "Маг" or class_name == "Клерик":
		max_mp += DiceSystem.roll_dice(4) + intelligence_modifier
		mp = max_mp
	
	emit_signal("level_up", level)
	update_ui()


## Додавання предмета до інвентаря
func add_item(item: Dictionary):
	inventory.append(item)
	emit_signal("item_added", item)
	update_ui()


## Видалення предмета з інвентаря
func remove_item(item_index: int):
	inventory.erase(item_index)
	update_ui()


## Оновлення UI
func update_ui():
	pass


## Парсинг шкоди з рядка (наприклад, "1d6" -> випадкове число)
func _parse_damage_dice(damage_str: String) -> int:
	var parts = damage_str.split("d")
	if parts.size() != 2:
		return 1
	
	var count = int(parts[0])
	var sides = int(parts[1])
	
	var total = 0
	for i in range(count):
		total += DiceSystem.roll_dice(sides)
	
	return total


## Оновлення стану ходу
func set_turn_active(active: bool):
	is_turn = active


## Сигнали
signal player_moved(new_cell: Vector2i)
signal attack_result(attacker: Node2D, target: Node2D, hit: bool, damage: int, is_critical: int)
signal critical_hit(attacker: Node2D, target: Node2D, damage: int)
signal defeated(entity: Node2D)
signal level_up(new_level: int)
signal item_added(item: Dictionary)
