extends Node
## CombatSystem - Система бою для D&D

# Список учасників бою
var combatants: Array = []

# Поточний хід
var current_turn_index: int = 0

# Чи триває бій
var is_combat_active: bool = false

# Поточний бій (для сигналів)
var current_combat_data: Dictionary = {}


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS


## Початок бою
func start_combat(players: Array, enemies: Array):
	# Скидаємо попередній бій
	combatants.clear()
	current_turn_index = 0
	is_combat_active = true
	
	# Додаємо гравців
	for player in players:
		combatants.append({
			"entity": player,
			"type": "player",
			"initiative": 0,
			"actions_left": player.get_meta("actions_per_turn", 1)
		})
	
	# Додаємо ворогів
	for enemy in enemies:
		combatants.append({
			"entity": enemy,
			"type": "enemy",
			"initiative": 0,
			"actions_left": enemy.get_meta("actions_per_turn", 1)
		})
	
	# Кидаємо ініціативу для всіх
	for i in range(combatants.size()):
		var combatant = combatants[i]
		var dex_modifier = combatant["entity"].get_meta("dexterity_modifier", 0)
		combatant["initiative"] = DiceSystem.roll_d20() + dex_modifier
	
	# Сортуємо за ініціативою (за спаданням)
	combatants.sort_custom(func(a, b):
		return a["initiative"] > b["initiative"]
	)
	
	# Визначаємо поточний хід
	current_turn_index = 0
	
	# Відправляємо сигнал про початок бою
	current_combat_data = {"players": players, "enemies": enemies}
	emit_signal("combat_started", current_combat_data)
	
	# Починаємо перший хід
	_next_turn()


## Завершення бою
func end_combat(victory: bool):
	is_combat_active = false
	emit_signal("combat_ended", victory, current_combat_data)


## Перехід до наступного ходу
func _next_turn():
	if current_turn_index >= combatants.size():
		current_turn_index = 0
	
	var current_combatant = combatants[current_turn_index]
	
	# Перевіряємо, чи учасник ще живий
	if current_combatant["entity"].get_meta("hp", 1) <= 0:
		current_turn_index += 1
		_next_turn()
		return
	
	# Відновлюємо дії для нового ходу
	current_combatant["actions_left"] = current_combatant["entity"].get_meta("actions_per_turn", 1)
	
	# Відправляємо сигнал про початок ходу
	emit_signal("turn_started", current_combatant)
	
	# Якщо це гравець, чекаємо на дію
	if current_combatant["type"] == "player":
		emit_signal("player_turn", current_combatant["entity"])
	else:
		# AI для ворога
		_ai_turn(current_combatant)


## Дія гравця (атака)
func player_attack(attacker: Node2D, target: Node2D, weapon: Dictionary):
	var attacker_data = _find_combatant(attacker)
	if attacker_data == null or attacker_data["actions_left"] <= 0:
		return false
	
	attacker_data["actions_left"] -= 1
	
	# Отримуємо характеристики атакуючого
	var attacker_str = attacker.get_meta("strength", 10)
	var attacker_dex = attacker.get_meta("dexterity", 10)
	var str_mod = floor((attacker_str - 10) / 2.0)
	var dex_mod = floor((attacker_dex - 10) / 2.0)
	
	# Визначаємо бонус атаки
	var attack_bonus = weapon.get("attack_bonus", 0)
	if weapon.get("type", "melee") == "melee":
		attack_bonus += str_mod
	else:
		attack_bonus += dex_mod
	
	# Кидок атаки
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
		var damage_mod = str_mod if weapon.get("type", "melee") == "melee" else dex_mod
		damage = damage_roll + damage_mod
		
		# Критичний влучний - подвійна шкода
		if is_critical == 1:
			damage *= 2
			emit_signal("critical_hit", attacker, target, damage)
	
		# Застосовуємо шкоду
		var new_hp = target.get_meta("hp", 1) - damage
		target.set_meta("hp", new_hp)
		
		emit_signal("attack_result", attacker, target, true, damage, is_critical)
	else:
		emit_signal("attack_result", attacker, target, false, 0, 0)
	
	# Перевіряємо, чи ціль померла
	if target.get_meta("hp", 1) <= 0:
		emit_signal("entity_defeated", target)
		# Видаляємо ворога з бою
		for i in range(combatants.size()):
			if combatants[i]["entity"] == target:
				combatants.erase(combatants[i])
				break
	
	# Якщо у гравця не залишилося дій, переходимо до наступного ходу
	if attacker_data["actions_left"] <= 0:
		current_turn_index += 1
		_next_turn()
	
	return is_hit


## Дія AI (ворог атакує)
func _ai_turn(combatant: Dictionary):
	await get_tree().create_timer(1.0).timeout  # Невелика затримка для візуального ефекту
	
	var enemy = combatant["entity"]
	var targets = []
	
	# Шукаємо цілі (гравців)
	for c in combatants:
		if c["type"] == "player" and c["entity"].get_meta("hp", 1) > 0:
			targets.append(c["entity"])
	
	if targets.is_empty():
		# Нікого не залишилося, завершуємо бій
		end_combat(true)
		return
	
	# Вибираємо випадкову ціль
	var target = targets[randi() % targets.size()]
	
	# Отримуємо атаки ворога
	var attacks = enemy.get_meta("attacks", [])
	if attacks.is_empty():
		# Якщо атаки немає, просто переходимо до наступного ходу
		current_turn_index += 1
		_next_turn()
		return
	
	# Вибираємо випадкову атаку
	var attack = attacks[randi() % attacks.size()]
	
	# Виконуємо атаку
	var is_hit = _enemy_attack(enemy, target, attack)
	
	# Переходимо до наступного ходу
	current_turn_index += 1
	_next_turn()


## Атака ворога
func _enemy_attack(attacker: Node2D, target: Node2D, attack: Dictionary) -> bool:
	var attacker_data = _find_combatant(attacker)
	if attacker_data == null:
		return false
	
	attacker_data["actions_left"] -= 1
	
	# Кидок атаки
	var attack_roll = DiceSystem.roll_d20() + attack.get("hit_bonus", 0)
	
	# Отримуємо AC цілі
	var target_ac = target.get_meta("ac", 10)
	
	# Перевіряємо влучний
	var is_hit = attack_roll >= target_ac
	
	# Визначаємо шкоду
	var damage = 0
	if is_hit:
		var damage_dice = attack.get("damage", "1d4")
		var damage_roll = _parse_damage_dice(damage_dice)
		damage = damage_roll + attack.get("damage_bonus", 0)
		
		# Застосовуємо шкоду
		var new_hp = target.get_meta("hp", 1) - damage
		target.set_meta("hp", new_hp)
		
		emit_signal("attack_result", attacker, target, true, damage, 0)
	else:
		emit_signal("attack_result", attacker, target, false, 0, 0)
	
	# Перевіряємо, чи ціль померла
	if target.get_meta("hp", 1) <= 0:
		emit_signal("entity_defeated", target)
		# Видаляємо гравця з бою
		for i in range(combatants.size()):
			if combatants[i]["entity"] == target:
				combatants.erase(combatants[i])
				break
		
		# Перевіряємо, чи всі гравці померли
		var players_alive = false
		for c in combatants:
			if c["type"] == "player":
				players_alive = true
				break
		if not players_alive:
			end_combat(false)
	
	return is_hit


## Пошук учасника в бою
func _find_combatant(entity: Node2D) -> Dictionary:
	for c in combatants:
		if c["entity"] == entity:
			return c
	return null


## Парсинг шкоди (наприклад, "1d6" -> випадкове число)
func _parse_damage_dice(damage_str: String) -> int:
	var parts = damage_str.split("d")
	if parts.size() != 2:
		return 1  # Повертаємо 1, якщо формат невірний
	
	var count = int(parts[0])
	var sides = int(parts[1])
	
	var total = 0
	for i in range(count):
		total += DiceSystem.roll_dice(sides)
	
	return total


## Сигнали
signal combat_started(combat_data: Dictionary)
signal combat_ended(victory: bool, combat_data: Dictionary)
signal turn_started(combatant: Dictionary)
signal player_turn(player: Node2D)
signal attack_result(attacker: Node2D, target: Node2D, hit: bool, damage: int, is_critical: int)
signal entity_defeated(entity: Node2D)
signal critical_hit(attacker: Node2D, target: Node2D, damage: int)
