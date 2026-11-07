extends Node

func _ready():
	randomize()

func roll_d6() -> int:
	return roll_dice(6)

func roll_d20() -> int:
	return roll_dice(20)

func roll_dice(sides: int) -> int:
	return randi() % sides + 1

func roll_multiple_dice(sides: int, count: int) -> int:
	var total = 0
	for i in range(count):
		total += roll_dice(sides)
	return total

func roll_with_modifier(sides: int, modifier: int) -> int:
	var base_roll = roll_dice(sides)
	var result = base_roll + modifier
	emit_signal("dice_roll_with_modifier", sides, base_roll, modifier, result)
	return result

func check_skill(sides: int, modifier: int, dc: int) -> bool:
	var roll = roll_with_modifier(sides, modifier)
	var success = roll >= dc
	emit_signal("skill_check", sides, modifier, dc, roll, success)
	return success

func is_critical_roll(roll: int, sides: int) -> int:
	if sides == 20 and roll == 20:
		return 1
	elif sides == 20 and roll == 1:
		return -1
	else:
		return 0

signal dice_roll_with_modifier(sides: int, base_roll: int, modifier: int, result: int)
signal skill_check(sides: int, modifier: int, dc: int, roll: int, success: bool)
