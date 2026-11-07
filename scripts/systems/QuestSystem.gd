extends Node

var current_quests: Array = []
var completed_quests: Array = []

func _ready():
	# Initialize with main quest
	var main_quest = {
		"id": "main_quest",
		"name": "Cult of Kaplos",
		"description": "Investigate the Cult of Kaplos and defeat Mal'gathor",
		"objectives": [
			{"description": "Find Cultist Camp", "completed": false},
			{"description": "Investigate Kamiltgon", "completed": false},
			{"description": "Enter Cave of Kaplos", "completed": false},
			{"description": "Defeat Mal'gathor", "completed": false}
		],
		"reward_xp": 1000,
		"reward_gold": 500
	}
	current_quests.append(main_quest)

func update_quest_objective(quest_id: String, objective_index: int):
	for quest in current_quests:
		if quest["id"] == quest_id and quest["objectives"].size() > objective_index:
			quest["objectives"][objective_index]["completed"] = true
			# Check if all objectives are completed
			var all_completed = true
			for objective in quest["objectives"]:
				if not objective["completed"]:
					all_completed = false
					break
			if all_completed:
				complete_quest(quest_id)

func complete_quest(quest_id: String):
	for i in range(current_quests.size()):
		if current_quests[i]["id"] == quest_id:
			completed_quests.append(current_quests[i])
			current_quests.remove_at(i)
			emit_signal("quest_completed", quest_id)
			break

func add_quest(quest: Dictionary):
	current_quests.append(quest)
	emit_signal("quest_added", quest["id"])

func get_current_quests() -> Array:
	return current_quests

func get_completed_quests() -> Array:
	return completed_quests

signal quest_added(quest_id: String)
signal quest_completed(quest_id: String)
