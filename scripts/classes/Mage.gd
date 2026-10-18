extends Player
## Mage.gd - Клас Маг

# Список заклинань
var spells: Array = []

# Кількість заклинань на день
var spells_per_day: Dictionary = {
	"level_1": 3,
	"level_2": 2,
	"level_3": 1
}

# Витрачені заклинання
var spells_used: Dictionary = {
	"level_1": 0,
	"level_2": 0,
	"level_3": 0
}


func _ready():
	# Встановлюємо базові характеристики для Мага
	class_name = "Маг"
	intelligence = 16
	dexterity = 14
	constitution = 10
	max_hp = 6 + constitution_modifier
	hp = max_hp
	max_mp = 10 + intelligence_modifier
	mp = max_mp
	actions_per_turn = 1
	
	# Здібності
	abilities = [
		{"name": "Магічна чутливість", "description": "+1 до виявлення магічних предметів", "level": 1, "effect": "detect_magic"},
		{"name": "Швидке чаклування", "description": "1 раз за бій може використовувати заклинання без витрат MP", "level": 3, "effect": "free_spell"},
		{"name": "Магічний захист", "description": "+2 до рятувальних кидків проти магії", "level": 5, "effect": "magic_resistance"},
		{"name": "Елементальний контроль", "description": "Заклинання вогню/льоду/блискавки заподіюють +1d6 шкоди", "level": 7, "effect": "elemental_damage"},
		{"name": "Магічна стійкість", "description": "Імунітет до 1 типу шкоди", "level": 10, "effect": "damage_immunity"},
		{"name": "Армагедон", "description": "1 раз за бій може використовувати заклинання 9 рівня без витрат MP", "level": 15, "effect": "armageddon"}
	]
	
	# Навички
	skills = {
		"Arcana": intelligence_modifier + 2,
		"History": intelligence_modifier + 1,
		"Perception": wisdom_modifier
	}
	
	# Обладнання
	equipment["weapon"] = {"name": "Палиця", "type": "melee", "damage_dice": "1d4", "attack_bonus": intelligence_modifier}
	
	# Заклинання
	spells = [
		{"name": "Вогняна куля", "level": 1, "mp_cost": 5, "damage": "1d6", "hit_bonus": intelligence_modifier, "type": "attack"},
		{"name": "Магічний щит", "level": 1, "mp_cost": 3, "effect": "+4 до AC на 1 хід", "type": "defense"},
		{"name": "Лідяна стріла", "level": 2, "mp_cost": 8, "damage": "1d8", "effect": "Уповільнює ворога на 1 хід", "type": "attack"},
		{"name": "Блискавка", "level": 3, "mp_cost": 12, "damage": "2d8", "effect": "Вражає 2 цілі", "type": "attack"}
	]
	
	# Оновлюємо UI
	update_ui()


## Вивчення нового заклинання
func learn_spell(spell: Dictionary):
	spells.append(spell)
	emit_signal("spell_learned", spell)


## Використання заклинання
func cast_spell(spell_name: String, target: Node2D = null) -> bool:
	var spell = null
	for s in spells:
		if s["name"] == spell_name:
			spell = s
			break
	
	if spell == null:
		return false
	
	# Перевіряємо, чи вистачає MP
	if mp < spell.get("mp_cost", 0):
		return false
	
	# Витрачаємо MP
	mp -= spell["mp_cost"]
	
	# Виконуємо ефект заклинання
	match spell["type"]:
		"attack":
			var damage = _parse_damage_dice(spell["damage"])
			var hit_roll = DiceSystem.roll_d20() + spell.get("hit_bonus", 0)
			var target_ac = target.get_meta("ac", 10)
			
			if hit_roll >= target_ac:
				var new_hp = target.get_meta("hp", 1) - damage
				target.set_meta("hp", new_hp)
				emit_signal("spell_cast", self, spell_name, target, true, damage)
				
				# Перевіряємо, чи ціль померла
				if target.get_meta("hp", 1) <= 0:
					emit_signal("entity_defeated", target)
			else:
				emit_signal("spell_cast", self, spell_name, target, false, 0)
			
			# Ефект заклинання (наприклад, уповільнення)
			if spell.has("effect"):
				if spell["effect"].contains("Уповільнює"):
					target.set_meta("slowed", true)
			
		"defense":
			# Збільшуємо AC
			var ac_bonus = spell.get("effect", "").get_integer_from_end(1)
			set_meta("ac_bonus", get_meta("ac_bonus", 0) + ac_bonus)
			emit_signal("spell_cast", self, spell_name, self, true, 0)
		
		_:
			emit_signal("spell_cast", self, spell_name, target, true, 0)
	
	# Оновлюємо UI
	update_ui()
	return true


## Відновлення заклинань (після відпочинку)
func restore_spells():
	spells_used["level_1"] = 0
	spells_used["level_2"] = 0
	spells_used["level_3"] = 0


## Оновлення MP
func update_mp():
	if mp < max_mp:
		mp = min(mp + 1, max_mp)
		update_ui()


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


## Сигнали
signal spell_learned(spell: Dictionary)
signal spell_cast(caster: Node2D, spell_name: String, target: Node2D, hit: bool, damage: int)
