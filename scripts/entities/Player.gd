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

var max_mp: int = 0
var mp: int = 0
var ac: int = 10
var speed: int = 1
var actions_per_turn: int = 1
var equipment: Dictionary = {
	"weapon": {"name": "Меч", "damage_dice": "1d6", "attack_bonus": 2},
	"armor": null,
	"shield": null
}
var inventory: Array = []
var current_cell: Vector2i = Vector2i(0, 0)
var is_turn: bool = false

func _ready():
	setup_class(class_name_val)
	update_ui()

func setup_class(p_class: String):
	class_name_val = p_class
	match p_class:
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
			mp = max_mp
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

func take_damage(amount: int):
	hp -= amount

func update_ui():
	pass

signal player_moved(new_cell: Vector2i)
signal attack_result(attacker: Node2D, target: Node2D, hit: bool, damage: int, is_critical: int)
signal defeated(entity: Node2D)
signal item_added(item: Dictionary)
