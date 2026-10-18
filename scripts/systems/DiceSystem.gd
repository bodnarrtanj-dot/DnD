extends Node
## DiceSystem - Система кидків кубиків для D&D механік

# Шляхи до текстур кубиків (потрібно додати зображення)
const DICE_TEXTURES = {
	"d6": [
		"res://assets/sprites/ui/dice_d6_1.png",
		"res://assets/sprites/ui/dice_d6_2.png",
		"res://assets/sprites/ui/dice_d6_3.png",
		"res://assets/sprites/ui/dice_d6_4.png",
		"res://assets/sprites/ui/dice_d6_5.png",
		"res://assets/sprites/ui/dice_d6_6.png"
	],
	"d20": [
		"res://assets/sprites/ui/dice_d20_1.png",
		"res://assets/sprites/ui/dice_d20_2.png",
		"res://assets/sprites/ui/dice_d20_3.png",
		# ... додано 20 текстур
	]
}

# Чи використовувати анімацію кубиків
var animate_dice: bool = true

# Швидкість анімації (в секундах)
var animation_speed: float = 0.1

# Поточна анімація
var is_animating: bool = false
var current_dice_type: String = ""
var current_roll_result: int = 0


func _ready():
	# Реєструємо сигнали
	process_mode = Node.PROCESS_MODE_ALWAYS


## Кидок кубика d6
func roll_d6() -> int:
	return _roll_dice("d6", 6)


## Кидок кубика d20
func roll_d20() -> int:
	return _roll_dice("d20", 20)


## Кидок кубика з довільною кількістю граней
func roll_dice(sides: int) -> int:
	return randi() % sides + 1


## Внутрішня функція для кидка кубика з анімацією
func _roll_dice(dice_type: String, sides: int) -> int:
	var result = randi() % sides + 1
	
	# Якщо анімація увімкнена, запускаємо її
	if animate_dice:
		current_dice_type = dice_type
		current_roll_result = result
		is_animating = true
		emit_signal("dice_roll_started", dice_type)
		
		# Симулюємо анімацію (у реальному проєкті це буде через AnimatedSprite2D)
		for i in range(10):
			var fake_result = randi() % sides + 1
			emit_signal("dice_roll_animation", dice_type, fake_result)
			await get_tree().create_timer(animation_speed).timeout
		
		is_animating = false
		emit_signal("dice_roll_finished", dice_type, result)
	
	return result


## Кидок декількох кубиків (наприклад, 2d6)
func roll_multiple_dice(dice_type: String, count: int) -> int:
	var total = 0
	for i in range(count):
		total += _roll_dice(dice_type, 6 if dice_type == "d6" else 20)
	return total


## Кидок з модифікатором (наприклад, d20 + 5)
func roll_with_modifier(dice_type: String, modifier: int) -> int:
	var base_roll = _roll_dice(dice_type, 6 if dice_type == "d6" else 20)
	var result = base_roll + modifier
	emit_signal("dice_roll_with_modifier", dice_type, base_roll, modifier, result)
	return result


## Перевірка навички (d20 + модифікатор проти DC)
func check_skill(dice_type: String, modifier: int, dc: int) -> bool:
	var roll = roll_with_modifier(dice_type, modifier)
	var success = roll >= dc
	emit_signal("skill_check", dice_type, modifier, dc, roll, success)
	return success


## Критичний успіх/промах
func is_critical_roll(roll: int, dice_type: String) -> int:
	# 20 на d20 = критичний успіх
	if dice_type == "d20" and roll == 20:
		return 1  # Критичний успіх
	# 1 на d20 = критичний промах
	elif dice_type == "d20" and roll == 1:
		return -1  # Критичний промах
	else:
		return 0  # Звичайний результат


## Сигнали
signal dice_roll_started(dice_type: String)
signal dice_roll_animation(dice_type: String, current_value: int)
signal dice_roll_finished(dice_type: String, result: int)
signal dice_roll_with_modifier(dice_type: String, base_roll: int, modifier: int, result: int)
signal skill_check(dice_type: String, modifier: int, dc: int, roll: int, success: bool)
