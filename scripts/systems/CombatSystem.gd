extends Node

var current_combatants: Array = []
var current_turn: int = 0
var initiative_order: Array = []

func start_combat(players: Array, monsters: Array):
	current_combatants = []
	# Add players
	for player in players:
		current_combatants.append({"entity": player, "type": "player", "initiative": DiceSystem.roll_d20()})
	# Add monsters
	for monster in monsters:
		current_combatants.append({"entity": monster, "type": "monster", "initiative": DiceSystem.roll_d20()})
	# Sort by initiative
	current_combatants.sort_custom(func(a, b): return b["initiative"] - a["initiative"])
	current_turn = 0
	_next_turn()

func _next_turn():
	# End previous turn
	if current_combatants.size() > 0:
		var previous = current_combatants[current_turn]
		if previous["entity"].has_method("set_turn_active"):
			previous["entity"].set_turn_active(false)
	# Move to next turn
	current_turn = (current_turn + 1) % current_combatants.size()
	var current = current_combatants[current_turn]
	if current["entity"].has_method("set_turn_active"):
		current["entity"].set_turn_active(true)
		emit_signal("turn_started", current["entity"])
		# Check if combat is over
		if _is_combat_over():
			end_combat()

func _is_combat_over() -> bool:
	var players_alive = 0
	var monsters_alive = 0
	for combatant in current_combatants:
		if combatant["entity"].hp > 0:
			if combatant["type"] == "player":
				players_alive += 1
			else:
				monsters_alive += 1
	return players_alive == 0 or monsters_alive == 0

func end_combat():
	emit_signal("combat_ended")
	GameManager.load_overworld()

func get_current_combatant():
	if current_combatants.size() > 0:
		return current_combatants[current_turn]
	return null

signal turn_started(entity)
signal combat_ended()
