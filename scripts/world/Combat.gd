extends Node2D
## Combat.gd - Клас бою

# Список учасників бою
var combatants: Array = []

# Поточний хід
var current_turn_index: int = 0

# Чи триває бій
var is_combat_active: bool = false

# Посилання на UI
@onready var ui: CanvasLayer = $UI
@onready var combat_log: RichTextLabel = $UI/HUD/CombatLog
@onready var turn_label: Label = $UI/HUD/TurnPanel/TurnLabel

# Список ворогів
var enemies: Array = []

# Поточний гравець
var current_player: Node2D


func _ready():
	# Отримуємо список ворогів з метаданих
	var enemy_list = get_meta("enemies", [])
	
	# Починаємо бій
	start_combat([GameManager.current_player], enemy_list)


## Початок бою
func start_combat(players: Array, enemy_list: Array):
	# Скидаємо попередній бій
	combatants.clear()
	current_turn_index = 0
	is_combat_active = true
	enemies = enemy_list
	
	# Додаємо гравців
	for player in players:
		combatants.append({
			"entity": player,
			"type": "player",
			"initiative": 0,
			"actions_left": player.get_meta("actions_per_turn", 1)
		})
	
	# Додаємо ворогів
	for enemy_data in enemy_list:
		var enemy_scene = null
		match enemy_data:
			"cultist":
				enemy_scene = preload("res://scenes/entities/cultist.tscn")
			"adept":
				enemy_scene = preload("res://scenes/entities/adept.tscn")
			"zombie":
				enemy_scene = preload("res://scenes/entities/zombie.tscn")
			"shadow_assassin":
				enemy_scene = preload("res://scenes/entities/shadow_assassin.tscn")
			"necromancer":
				enemy_scene = preload("res://scenes/entities/necromancer.tscn")
			"cult_leader":
				enemy_scene = preload("res://scenes/entities/cult_leader.tscn")
			_:
				enemy_scene = preload("res://scenes/entities/cultist.tscn")
		
		if enemy_scene:
			var enemy = enemy_scene.instantiate()
			add_child(enemy)
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
	
	# Логуємо початок бою
	log_message("Бій розпочато!")
	
	# Починаємо перший хід
	_next_turn()


## Завершення бою
func end_combat(victory: bool):
	is_combat_active = false
	
	if victory:
		log_message("Перемога! Ви отримали досвід та скарби.")
		# Видаляємо всіх ворогів
		for child in get_children():
			if child is Monster:
				child.queue_free()
		
		# Видаємо досвід
		var total_xp = 0
		for enemy in enemies:
			total_xp += enemy.get_meta("xp_reward", 50)
		GameManager.current_player.add_xp(total_xp)
		
		# Повертаємося до данжу
		GameManager.return_to_world()
	else:
		log_message("Поразка! Ви програли бій.")
		# Повертаємося до світу
		GameManager.return_to_world()


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
	
	# Оновлюємо UI
	if current_combatant["type"] == "player":
		current_player = current_combatant["entity"]
		turn_label.text = "Хід: %s" % current_player.name
		log_message("Хід гравця: %s" % current_player.name)
	else:
		turn_label.text = "Хід: %s" % current_combatant["entity"].name
		log_message("Хід ворога: %s" % current_combatant["entity"].name)
		
		# AI для ворога
		_ai_turn(current_combatant)


## Дія AI (ворог атакує)
func _ai_turn(combatant: Dictionary):
	await get_tree().create_timer(1.0).timeout
	
	var enemy = combatant["entity"]
	
	# Шукаємо цілі (гравців)
	var targets = []
	for c in combatants:
		if c["type"] == "player" and c["entity"].get_meta("hp", 1) > 0:
			targets.append(c["entity"])
	
	if targets.is_empty():
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
		if attack.has("damage"):
			var damage_str = attack["damage"]
			var parts = damage_str.split(" ")
			var dice_part = parts[0]
			var bonus = 0
			
			if parts.size() > 1 and parts[1].contains("+"):
				bonus = int(parts[1].replace("+", ""))
			
			var dice_parts = dice_part.split("d")
			if dice_parts.size() == 2:
				var count = int(dice_parts[0])
				var sides = int(dice_parts[1])
				for i in range(count):
					damage += DiceSystem.roll_dice(sides)
			damage += bonus
			
			# Застосовуємо шкоду
			target.take_damage(damage)
			
			log_message("%s влучає в %s! Шкода: %d" % [attacker.name, target.name, damage])
			
			# Перевіряємо, чи ціль померла
			if target.get_meta("hp", 1) <= 0:
				log_message("%s переміг %s!" % [attacker.name, target.name])
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
				return true
	else:
		log_message("%s промахнувся по %s!" % [attacker.name, target.name])
	
	return is_hit


## Пошук учасника в бою
func _find_combatant(entity: Node2D) -> Dictionary:
	for c in combatants:
		if c["entity"] == entity:
			return c
	return null


## Обробка натискання кнопки "Атака"
func _on_attack_button_pressed():
	var current_combatant = combatants[current_turn_index]
	
	if current_combatant["type"] != "player":
		return
	
	if current_combatant["actions_left"] <= 0:
		log_message("У вас немає дій!")
		return
	
	# Шукаємо найближчого ворога
	var closest_enemy = null
	var min_distance = INF
	
	for enemy in enemies:
		# Шукаємо ворога в списку combatants
		for c in combatants:
			if c["entity"] == enemy and c["entity"].get_meta("hp", 1) > 0:
				var distance = (c["entity"].global_position - current_player.global_position).length()
				if distance < min_distance:
					min_distance = distance
					closest_enemy = c["entity"]
					break
	
	if closest_enemy:
		current_combatant["actions_left"] -= 1
		current_player.attack(closest_enemy)
		log_message("%s атакує %s!" % [current_player.name, closest_enemy.name])


## Обробка натискання кнопки "Заклинання"
func _on_spell_button_pressed():
	var current_combatant = combatants[current_turn_index]
	
	if current_combatant["type"] != "player":
		return
	
	if current_combatant["actions_left"] <= 0:
		log_message("У вас немає дій!")
		return
	
	# Поки що просто логуємо
	log_message("Заклинання - ще не реалізовано")


## Обробка натискання кнопки "Захист"
func _on_defend_button_pressed():
	var current_combatant = combatants[current_turn_index]
	
	if current_combatant["type"] != "player":
		return
	
	if current_combatant["actions_left"] <= 0:
		log_message("У вас немає дій!")
		return
	
	current_combatant["actions_left"] -= 1
	current_player.set_meta("ac_bonus", current_player.get_meta("ac_bonus", 0) + 2)
	log_message("%s використовує захист! AC +2" % current_player.name)


## Обробка натискання кнопки "Завершити хід"
func _on_end_turn_button_pressed():
	current_turn_index += 1
	_next_turn()


## Додавання повідомлення до логу
func log_message(message: String):
	combat_log.text += "\n" + message
	# Прокручуємо лог вниз
	combat_log.scroll_to_line(combat_log.get_line_count() - 1)
