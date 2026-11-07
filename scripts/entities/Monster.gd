extends CharacterBody2D

var monster_name: String = "Монстр"
var type: String = "monster"
var level: int = 1
var strength: int = 10
var dexterity: int = 10
var constitution: int = 10
var intelligence: int = 10
var wisdom: int = 10
var charisma: int = 10
var max_hp: int = 10
var hp: int = 10
var ac: int = 10
var attacks: Array = []
var spells: Array = []
var xp_reward: int = 50
var speed: int = 1
var actions_per_turn: int = 1

func _ready():
	_setup_monster_stats()

func _setup_monster_stats():
	match type:
		"cultist":
			monster_name = "Культист"
			strength = 10
			dexterity = 12
			max_hp = 10
			hp = max_hp
			ac = 12
			attacks = [{"name": "Кинджал", "damage": "1d4 + 2", "hit_bonus": 4, "type": "melee"}]
			xp_reward = 50
		"zombie":
			monster_name = "Зомбі"
			strength = 13
			dexterity = 6
			max_hp = 15
			hp = max_hp
			ac = 8
			attacks = [{"name": "Удар", "damage": "1d8 + 2", "hit_bonus": 4, "type": "melee"}]
			xp_reward = 60
		"shadow_assassin":
			monster_name = "Тіньовий вбивця"
			dexterity = 18
			max_hp = 20
			hp = max_hp
			ac = 14
			attacks = [{"name": "Тіньовий кинджал", "damage": "1d6 + 3", "hit_bonus": 6, "type": "melee"}]
			xp_reward = 100
		"necromancer":
			monster_name = "Некромант"
			intelligence = 16
			max_hp = 25
			hp = max_hp
			ac = 12
			spells = [{"name": "Темна хвиля", "damage": "2d6", "hit_bonus": 5, "type": "spell"}]
			xp_reward = 150
		"cult_leader":
			monster_name = "Мал'гатхор"
			wisdom = 18
			max_hp = 100
			hp = max_hp
			ac = 18
			attacks = [{"name": "Темна хвиля", "damage": "2d6", "hit_bonus": 7, "type": "spell"}]
			xp_reward = 1000

func get_strength_modifier() -> int:
	return floor((strength - 10) / 2.0)

func get_dexterity_modifier() -> int:
	return floor((dexterity - 10) / 2.0)

func attack(target: Node2D) -> bool:
	if attacks.is_empty():
		return false
	var attack = attacks[randi() % attacks.size()]
	var attack_roll = DiceSystem.roll_d20() + attack.get("hit_bonus", 0)
	var target_ac = target.get("ac", 10) if target.has_method("get") else 10
	var is_hit = attack_roll >= target_ac
	var damage = 0
	if is_hit and attack.has("damage"):
		damage = _parse_damage_dice(attack["damage"])
		target.take_damage(damage)
		emit_signal("attack_result", self, target, true, damage)
	else:
		emit_signal("attack_result", self, target, false, 0)
	return is_hit

func take_damage(amount: int):
	hp -= amount
	if hp <= 0:
		hp = 0
		emit_signal("defeated", self)

func _parse_damage_dice(damage_str: String) -> int:
	var parts = damage_str.split(" ")
	var dice_part = parts[0]
	var bonus = 0
	if parts.size() > 1 and parts[1].contains("+"):
		bonus = int(parts[1].replace("+", ""))
	var dice_parts = dice_part.split("d")
	if dice_parts.size() != 2:
		return bonus
	var count = int(dice_parts[0])
	var sides = int(dice_parts[1])
	var total = bonus
	for i in range(count):
		total += DiceSystem.roll_dice(sides)
	return total

signal attack_result(attacker: Node2D, target: Node2D, hit: bool, damage: int)
signal defeated(entity: Node2D)
