extends Player
## Cleric.gd - Клас Клерик

# Домен клерика
var domain: String = "Світло"

# Список заклинань
var spells: Array = []

# Кількість заклинань на день
var spells_per_day: Dictionary = {
	"level_1": 4,
	"level_2": 3,
	"level_3": 2
}


func _ready():
	# Встановлюємо базові характеристики для Клерика
	class_name = "Клерик"
	wisdom = 16
	constitution = 14
	charisma = 12
	max_hp = 8 + constitution_modifier
	hp = max_hp
	max_mp = 10 + wisdom_modifier
	mp = max_mp
	actions_per_turn = 1
	
	# Здібності залежно від домену
	match domain:
		"Світло":
			abilities = [
				{"name": "Божественний домен (Світло)", "description": "+1 до урону від заклинань світла", "level": 1, "effect": "light_domain"},
				{"name": "Свята символія", "description": "1 раз за день може використовувати заклинання 1 рівня без витрат MP", "level": 1, "effect": "holy_symbol"},
				{"name": "Благословення", "description": "Союзники отримують +1 до кидків атаки на 1 хід", "level": 3, "effect": "blessing"},
				{"name": "Чудотворення", "description": "Лікування ран відновлює +1d8 HP", "level": 5, "effect": "miracle"},
				{"name": "Свята стійкість", "description": "+2 до рятувальних кидків проти отрути та хвороб", "level": 7, "effect": "holy_resistance"},
				{"name": "Відродження", "description": "1 раз за день може воскресити союзника з 50% HP", "level": 10, "effect": "resurrection"}
			]
		"Темрява":
			abilities = [
				{"name": "Божественний домен (Темрява)", "description": "+1 до урону від заклинань темряви", "level": 1, "effect": "dark_domain"},
				{"name": "Свята символія", "description": "1 раз за день може використовувати заклинання 1 рівня без витрат MP", "level": 1, "effect": "holy_symbol"},
				{"name": "Прокляття", "description": "Вороги отримують -1 до кидків атаки на 1 хід", "level": 3, "effect": "curse"},
				{"name": "Темна хвиля", "description": "Заклинання темряви заподіюють +1d6 шкоди", "level": 5, "effect": "dark_wave"}
			]
		"Вогонь":
			abilities = [
				{"name": "Божественний домен (Вогонь)", "description": "+1 до урону від заклинань вогню", "level": 1, "effect": "fire_domain"},
				{"name": "Свята символія", "description": "1 раз за день може використовувати заклинання 1 рівня без витрат MP", "level": 1, "effect": "holy_symbol"},
				{"name": "Вогонь покарання", "description": "Заклинання вогню заподіюють +1d6 шкоди", "level": 3, "effect": "fire_punishment"}
			]
		"Лікування":
			abilities = [
				{"name": "Божественний домен (Лікування)", "description": "+1 до ефекту лікувальних заклинань", "level": 1, "effect": "healing_domain"},
				{"name": "Свята символія", "description": "1 раз за день може використовувати заклинання 1 рівня без витрат MP", "level": 1, "effect": "holy_symbol"},
				{"name": "Відновлення", "description": "Лікування ран відновлює +1d8 HP", "level": 3, "effect": "restoration"}
			]
		_:
			abilities = [
				{"name": "Божественний домен", "description": "Вибір домену", "level": 1, "effect": "domain"},
				{"name": "Свята символія", "description": "1 раз за день може використовувати заклинання 1 рівня без витрат MP", "level": 1, "effect": "holy_symbol"}
			]
	
	# Навички
	skills = {
		"Medicine": wisdom_modifier + 2,
		"Religion": intelligence_modifier + 1,
		"Perception": wisdom_modifier + 1
	}
	
	# Обладнання
	equipment["weapon"] = {"name": "Буздиган", "type": "melee", "damage_dice": "1d6", "attack_bonus": 1}
	equipment["armor"] = {"name": "Ланцюгова броня", "ac_bonus": 3}
	equipment["shield"] = {"name": "Дерев'яний щит", "ac_bonus": 2}
	
	# Заклинання залежно від домену
	match domain:
		"Світло":
			spells = [
				{"name": "Лікування ран", "level": 1, "mp_cost": 5, "effect": "1d8 + wisdom_modifier HP", "type": "healing"},
				{"name": "Святий світло", "level": 1, "mp_cost": 4, "damage": "1d6", "type": "attack"},
				{"name": "Захист від зла", "level": 2, "mp_cost": 8, "effect": "+2 до AC і рятувальних кидків для всіх союзників на 1 хід", "type": "defense"},
				{"name": "Вогонь покарання", "level": 3, "mp_cost": 10, "damage": "2d6", "type": "attack"}
			]
		"Темрява":
			spells = [
				{"name": "Темна куля", "level": 1, "mp_cost": 5, "damage": "1d6", "type": "attack"},
				{"name": "Прокляття", "level": 1, "mp_cost": 4, "effect": "-1 до кидків атаки для ворога на 1 хід", "type": "debuff"},
				{"name": "Темна хвиля", "level": 2, "mp_cost": 8, "damage": "2d6", "type": "attack"}
			]
		"Вогонь":
			spells = [
				{"name": "Вогняна куля", "level": 1, "mp_cost": 5, "damage": "1d6", "type": "attack"},
				{"name": "Вогняний щит", "level": 1, "mp_cost": 4, "effect": "+2 до AC, заподіює 1d4 шкоди при атаці", "type": "defense"},
				{"name": "Вогонь покарання", "level": 2, "mp_cost": 8, "damage": "2d6", "type": "attack"}
			]
		"Лікування":
			spells = [
				{"name": "Лікування ран", "level": 1, "mp_cost": 5, "effect": "1d8 + wisdom_modifier HP", "type": "healing"},
				{"name": "Масове лікування", "level": 2, "mp_cost": 8, "effect": "1d6 + wisdom_modifier HP для всіх союзників", "type": "healing"},
				{"name": "Відновлення", "level": 3, "mp_cost": 10, "effect": "Виліковує всі рани та хвороби", "type": "healing"}
			]
		_:
			spells = [
				{"name": "Лікування ран", "level": 1, "mp_cost": 5, "effect": "1d8 + wisdom_modifier HP", "type": "healing"},
				{"name": "Святий світло", "level": 1, "mp_cost": 4, "damage": "1d6", "type": "attack"}
			]
	
	# Оновлюємо UI
	update_ui()


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
		"healing":
			var heal_amount = _parse_healing_effect(spell["effect"])
			var new_hp = target.get_meta("hp", 1) + heal_amount
			target.set_meta("hp", min(new_hp, target.get_meta("max_hp", 1)))
			emit_signal("spell_cast", self, spell_name, target, true, heal_amount)
			
		"attack":
			var damage = _parse_damage_dice(spell.get("damage", "1d4"))
			var hit_roll = DiceSystem.roll_d20() + wisdom_modifier
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
			
		"defense":
			# Збільшуємо AC
			var ac_bonus = spell.get("effect", "").get_integer_from_end(1)
			if target:
				target.set_meta("ac_bonus", target.get_meta("ac_bonus", 0) + ac_bonus)
			else:
				set_meta("ac_bonus", get_meta("ac_bonus", 0) + ac_bonus)
			emit_signal("spell_cast", self, spell_name, target, true, 0)
			
		"debuff":
			# Застосовуємо дебаф
			if spell.get("effect", "").contains("-1 до кидків атаки"):
				target.set_meta("attack_penalty", target.get_meta("attack_penalty", 0) - 1)
			emit_signal("spell_cast", self, spell_name, target, true, 0)
			
		_:
			emit_signal("spell_cast", self, spell_name, target, true, 0)
	
	# Оновлюємо UI
	update_ui()
	return true


## Парсинг ефекту лікування (наприклад, "1d8 + wisdom_modifier HP")
func _parse_healing_effect(effect_str: String) -> int:
	if effect_str.contains("d"):
		var damage_part = effect_str.split(" ")[0]
		var heal_amount = _parse_damage_dice(damage_part)
		if effect_str.contains("wisdom_modifier"):
			heal_amount += wisdom_modifier
		return heal_amount
	return 1


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
signal spell_cast(caster: Node2D, spell_name: String, target: Node2D, hit: bool, effect_value: int)
