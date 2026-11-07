extends CharacterBody2D

var display_name: String = "Авантюрист"
var race: String = "Людина"
var class_name_val: String = "Воїн"
var level: int = 1
var xp: int = 0
var xp_to_next_level: int = 100

var strength: int = 10
var dexterity: int = 10
var constitution: int = 10
var intelligence: int = 10
var wisdom: int = 10
var charisma: int = 10

var _hp: int = 10
var max_hp: int = 10
var hp: int:
	get: return _hp
	set(value):
		_hp = value
		if _hp <= 0:
			_hp = 0
			emit_signal("defeated", self)
		elif _hp > max_hp:
			_hp = max_hp

var _mp: int = 0
var max_mp: int = 0
var mp: int:
	get: return _mp
	set(value):
		_mp = value
		if _mp < 0:
			_mp = 0
		elif _mp > max_mp:
			_mp = max_mp

var ac: int = 10
var speed: int = 1
var actions_per_turn: int = 1
var equipment: Dictionary = {
	"weapon": {"name": "Меч", "type": "melee", "damage_dice": "1d6", "attack_bonus": 2},
	"armor": {"name": "Ланцюгова броня", "ac_bonus": 3},
	"shield": {"name": "Дерев'яний щит", "ac_bonus": 2}
}
var inventory: Array = []
var current_cell: Vector2i = Vector2i(0, 0)
var is_turn: bool = false

func _ready():
	_setup_class_stats()
	update_ui()

func _setup_class_stats():
	match class_name_val:
		"Воїн":
			strength = 16
			dexterity = 14
			constitution = 16
			max_hp = 10
			hp = max_hp
		"Маг":
			intelligence = 16
			max_hp = 6
			hp = max_hp
			equipment["weapon"] = {"name": "Палиця", "type": "melee", "damage_dice": "1d4", "attack_bonus": 0}
		"Слідопит":
			dexterity = 16
			max_hp = 8
			hp = max_hp
			equipment["weapon"] = {"name": "Лук", "type": "ranged", "damage_dice": "1d8", "attack_bonus": 2}
		"Клерик":
			wisdom = 16
			max_hp = 8
			hp = max_hp
			equipment["weapon"] = {"name": "Буздиган", "type": "melee", "damage_dice": "1d6", "attack_bonus": 1}

func setup_class(class_name: String):
	class_name_val = class_name
	match class_name:
		"Воїн":
			strength = 16
			dexterity = 14
			constitution = 16
			max_hp = 10
			equipment["weapon"] = {"name": "Меч", "damage_dice": "1d6", "attack_bonus": 2}
		"Маг":
			intelligence = 16
			dexterity = 14
			constitution = 10
			max_hp = 6
			max_mp = 10
			equipment["weapon"] = {"name": "Палиця", "damage_dice": "1d4", "attack_bonus": 0}
		"Слідопит":
			dexterity = 16
			wisdom = 14
			constitution = 14
			max_hp = 8
			equipment["weapon"] = {"name": "Лук", "damage_dice": "1d8", "attack_bonus": 2}
		"Клерик":
			wisdom = 16
			constitution = 14
			charisma = 12
			max_hp = 8
			equipment["weapon"] = {"name": "Буздиган", "damage_dice": "1d6", "attack_bonus": 1}
	hp = max_hp
	mp = max_mp

func get_strength_modifier() -> int:
	return floor((strength - 10) / 2.0)

func get_dexterity_modifier() -> int:
	return floor((dexterity - 10) / 2.0)

func move_to_cell(target_cell: Vector2i):
	var overworld = get_parent()
	if overworld and overworld.has_method("is_cell_walkable"):
		if overworld.is_cell_walkable(target_cell):
			current_cell = target_cell
			global_position = overworld.cell_to_world(current_cell)
			emit_signal("player_moved", current_cell)

func attack(target: Node2D) -> bool:
	if not is_turn:
		return false
	var weapon = equipment.get("weapon", null)
	if weapon == null:
		return false
	var attack_bonus = weapon.get("attack_bonus", 0)
	if weapon.get("type", "melee") == "melee":
		attack_bonus += get_strength_modifier()
	else:
		attack_bonus += get_dexterity_modifier()
	var attack_roll = DiceSystem.roll_d20() + attack_bonus
	var target_ac = target.ac if "ac" in target else 10
	var is_hit = attack_roll >= target_ac
	var damage = 0
	if is_hit:
		var damage_dice = weapon.get("damage_dice", "1d6")
		damage = _parse_damage_dice(damage_dice) + get_strength_modifier()
		target.take_damage(damage)
		emit_signal("attack_result", self, target, true, damage, 0)
	else:
		emit_signal("attack_result", self, target, false, 0, 0)
	return is_hit

func take_damage(amount: int):
	hp -= amount

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

func set_turn_active(active: bool):
	is_turn = active

func update_ui():
	pass

signal player_moved(new_cell: Vector2i)
signal attack_result(attacker: Node2D, target: Node2D, hit: bool, damage: int, is_critical: int)
signal defeated(entity: Node2D)
signal item_added(item: Dictionary)
