extends Node
## QuestSystem - Система квестів

# Список активних квестів
var active_quests: Array = []

# Список виконаних квестів
var completed_quests: Array = []

# Поточний вибраний квест
var selected_quest: Dictionary = null


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS


## Додавання квесту
func add_quest(quest_data: Dictionary):
	# Перевіряємо, чи квест вже доданий
	for quest in active_quests:
		if quest.get("id", "") == quest_data.get("id", ""):
			return
	
	active_quests.append(quest_data)
	emit_signal("quest_added", quest_data)


## Видалення квесту
func remove_quest(quest_id: String):
	for i in range(active_quests.size()):
		if active_quests[i].get("id", "") == quest_id:
			active_quests.erase(active_quests[i])
			emit_signal("quest_removed", quest_id)
			return


## Завершення квесту
func complete_quest(quest_id: String):
	var quest = null
	for i in range(active_quests.size()):
		if active_quests[i].get("id", "") == quest_id:
			quest = active_quests[i]
			active_quests.erase(active_quests[i])
			break
	
	if quest == null:
		return
	
	completed_quests.append(quest)
	emit_signal("quest_completed", quest)
	
	# Видаємо нагороду
	if quest.has("reward_xp"):
		GameManager.current_player.add_xp(quest["reward_xp"])
	if quest.has("reward_gold"):
		GameManager.current_player.add_gold(quest["reward_gold"])
	if quest.has("reward_item"):
		GameManager.current_player.add_item(quest["reward_item"])


## Оновлення цілей квесту
func update_quest_objective(quest_id: String, objective_type: String, target: String):
	for quest in active_quests:
		if quest.get("id", "") == quest_id:
			for objective in quest.get("objectives", []):
				if objective.get("type", "") == objective_type and objective.get("target", "") == target:
					objective["completed"] = true
					emit_signal("quest_objective_updated", quest_id, objective)
					
					# Перевіряємо, чи всі цілі виконані
					var all_completed = true
					for obj in quest.get("objectives", []):
						if not obj.get("completed", false):
							all_completed = false
							break
					
					if all_completed:
						complete_quest(quest_id)
					return


## Отримання квесту за ID
func get_quest(quest_id: String) -> Dictionary:
	for quest in active_quests:
		if quest.get("id", "") == quest_id:
			return quest
	return null


## Вибір квесту
func select_quest(quest_id: String):
	selected_quest = get_quest(quest_id)
	emit_signal("quest_selected", selected_quest)


## Отримання всіх активних квестів
func get_active_quests() -> Array:
	return active_quests


## Отримання всіх виконаних квестів
func get_completed_quests() -> Array:
	return completed_quests


## Сигнали
signal quest_added(quest: Dictionary)
signal quest_removed(quest_id: String)
signal quest_completed(quest: Dictionary)
signal quest_objective_updated(quest_id: String, objective: Dictionary)
signal quest_selected(quest: Dictionary)
