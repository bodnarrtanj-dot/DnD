extends CharacterBody2D
class_name Monster
## Monster - Клас монстра

# Базові характеристики
var name: String = "Монстр"
var type: String = "monster"
var level: int = 1

# Характеристики
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

# HP
var max_hp: int = 10
var hp: int = 10

# Клас броні (AC)
var ac: int = 10

# Атаки
var attacks: Array = []

# Заклинання (для магічних монстрів)
var spells: Array = []

# Слабкості
var weaknesses: Array = []

# Стійкості
var resistances: Array = []

# Досвід за перемогу
var xp_reward: int = 50

# Швидкість
var speed: int = 1

# Кількість дій за хід
var actions_per_turn: int = 1


func _ready():
	# Налаштування залежно від типу
	_setup_monster_stats()


## Налаштування характеристик залежно від типу
func _setup_monster_stats():
	match type:
		"cultist":
			name = "Культист"
			strength = 10
			dexterity = 12
			constitution = 10
			max_hp = 10
			hp = max_hp
			ac = 12
			attacks = [
				{"name": "Кинджал", "damage": "1d4 + 2", "hit_bonus": 4, "type": "melee"}
			]
			xp_reward = 50
		
		"adept":
			name = "Адепт"
			intelligence = 14
			dexterity = 10
			constitution = 10
			max_hp = 15
			hp = max_hp
			ac = 10
			spells = [
				{"name": "Темна куля", "damage": "1d6", "hit_bonus": 5, "mp_cost": 0, "type": "spell"}
			]
			xp_reward = 75
		
		"zombie":
			name = "Зомбі"
			strength = 13
			dexterity = 6
			constitution = 16
			max_hp = 15
			hp = max_hp
			ac = 8
			attacks = [
				{"name": "Удар", "damage": "1d8 + 2", "hit_bonus": 4, "type": "melee"}
			]
			weaknesses = ["sacred_magic"]
			xp_reward = 60
		
		"shadow_assassin":
			name = "Тіньовий вбивця"
			dexterity = 18
			strength = 10
			constitution = 10
			max_hp = 20
			hp = max_hp
			ac = 14
			attacks = [
				{"name": "Тіньовий кинджал", "damage": "1d6 + 3", "hit_bonus": 6, "type": "melee"}
			]
			weaknesses = ["fire"]
			xp_reward = 100
		
		"necromancer":
			name = "Некромант"
			intelligence = 16
			constitution = 10
			max_hp = 25
			hp = max_hp
			ac = 12
			spells = [
				{"name": "Виклик зомбі", "effect": "summon_zombie", "cooldown": 3, "type": "summon"},
				{"name": "Темна хвиля", "damage": "2d6", "hit_bonus": 5, "type": "spell"}
			]
			weaknesses = ["sacred_magic"]
			xp_reward = 150
		
		"priest_of_kaplos":
			name = "Жерець Каплоса"
			wisdom = 16
			constitution = 14
			max_hp = 25
			hp = max_hp
			ac = 14
			spells = [
				{"name": "Прокляття Каплоса", "effect": "curse", "dc": 16, "stat": "wisdom", "type": "debuff"},
				{"name": "Темна хвиля", "damage": "2d6", "hit_bonus": 6, "type": "spell"}
			]
			weaknesses = ["sacred_magic"]
			xp_reward = 200
		
		"cult_leader":
			name = "Мал'гатхор"
			wisdom = 18
			constitution = 16
			charisma = 16
			max_hp = 100
			hp = max_hp
			ac = 18
			attacks = [
				{"name": "Темна хвиля", "damage": "2d6", "hit_bonus": 7, "type": "spell"}
			]
			spells = [
				{"name": "Прокляття Каплоса", "effect": "curse_all", "dc": 20, "stat": "wisdom", "type": "debuff"},
				{"name": "Активація Фрагмента Душі", "effect": "empower_enemies", "type": "buff"},
				{"name": "Пожирання світла", "damage": "3d10", "hit_bonus": 10, "ignore_ac": true, "type": "spell"}
			]
			weaknesses = ["sacred_magic"]
			resistances = ["dark_magic", "necrotic"]
			xp_reward = 1000


## Обчислення модифікатора характеристики
func _calculate_modifier(value: int) -> int:
	return floor((value - 10) / 2.0)


## Атака монстра
func attack(target: Node2D) -> bool:
	if attacks.is_empty():
		return false
	
	# Вибираємо випадкову атаку
	var attack = attacks[randi() % attacks.size()]
	
	# Кидок атаки
	var attack_roll = DiceSystem.roll_d20() + attack.get("hit_bonus", 0)
	
	# Отримуємо AC цілі
	var target_ac = target.get_meta("ac", 10)
	
	# Перевіряємо влучний
	var is_hit = attack_roll >= target_ac
	
	# Визначаємо шкоду
	var damage = 0
	if is_hit:
		if attack.has("damage"):
			damage = _parse_damage_dice(attack["damage"])
			target.take_damage(damage)
		
		emit_signal("attack_result", self, target, true, damage)
	else:
		emit_signal("attack_result", self, target, false, 0)
	
	return is_hit


## Використання заклинання
func cast_spell(spell_name: String, target: Node2D = null) -> bool:
	var spell = null
	for s in spells:
		if s["name"] == spell_name:
			spell = s
			break
	
	if spell == null:
		return false
	
	# Виконуємо ефект заклинання
	match spell["type"]:
		"spell":
			var damage = _parse_damage_dice(spell.get("damage", "1d4"))
			var hit_roll = DiceSystem.roll_d20() + spell.get("hit_bonus", 0)
			var target_ac = target.get_meta("ac", 10)
			
			if hit_roll >= target_ac:
				target.take_damage(damage)
				emit_signal("spell_cast", self, spell_name, target, true, damage)
				
				# Перевіряємо, чи ціль померла
				if target.get_meta("hp", 1) <= 0:
					emit_signal("entity_defeated", target)
			else:
				emit_signal("spell_cast", self, spell_name, target, false, 0)
			
		"summon":
			# Викликаємо монстра
			if spell["effect"] == "summon_zombie":
				var zombie_scene = preload("res://scenes/entities/zombie.tscn")
				var zombie = zombie_scene.instantiate()
				zombie.global_position = global_position + Vector2(100, 100)
				get_parent().add_child(zombie)
				emit_signal("spell_cast", self, spell_name, zombie, true, 0)
			
		"debuff":
			# Застосовуємо дебаф
			if spell["effect"] == "curse":
				var dc = spell.get("dc", 10)
				var stat = spell.get("stat", "wisdom")
				var save_roll = DiceSystem.roll_d20() + target.get_meta(stat + "_modifier", 0)
				
				if save_roll < dc:
					# Ворог не зміг врятуватися
					target.set_meta("cursed", true)
					emit_signal("spell_cast", self, spell_name, target, true, 0)
				else:
					emit_signal("spell_cast", self, spell_name, target, false, 0)
			
		"buff":
			# Застосовуємо баф
			if spell["effect"] == "empower_enemies":
				# Всі вороги отримують +2 до урону
				for child in get_parent().get_children():
					if child is Monster:
						child.set_meta("damage_bonus", child.get_meta("damage_bonus", 0) + 2)
				emit_signal("spell_cast", self, spell_name, self, true, 0)
			
		_:
			emit_signal("spell_cast", self, spell_name, target, true, 0)
	
	return true


## Отримання шкоди
func take_damage(amount: int):
	hp -= amount
	if hp <= 0:
		hp = 0
		emit_signal("defeated", self)


## Парсинг шкоди з рядка (наприклад, "1d6 + 2" -> випадкове число)
func _parse_damage_dice(damage_str: String) -> int:
	var parts = damage_str.split(" ")
	var dice_part = parts[0]
	var bonus = 0
	
	if parts.size() > 1 and parts[1].contains("+"):
		bonus = int(parts[1].replace("+", ""))
	
	var dice_parts = dice_part.split("d")
	if dice_parts.size() != 2:
		return bonus
	
	var count = int(dice_parts[0])
	var sides = int(dice_parts[1])
	
	var total = bonus
	for i in range(count):
		total += DiceSystem.roll_dice(sides)
	
	return total


## Сигнали
signal attack_result(attacker: Node2D, target: Node2D, hit: bool, damage: int)
signal spell_cast(caster: Node2D, spell_name: String, target: Node2D, hit: bool, damage: int)
signal defeated(entity: Node2D)
