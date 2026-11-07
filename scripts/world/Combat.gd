extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var monster: CharacterBody2D = $Monster

func _ready():
	# Initialize combat
	if GameManager.current_player:
		player = GameManager.current_player
		player.position = Vector2(-200, 0)
		
	# Create monster based on type
	if GameManager.current_monsters.size() > 0:
		var monster_type = GameManager.current_monsters[0]
		create_monster(monster_type)

func create_monster(monster_type: String):
	var monster_scene = preload("res://scenes/entities/" + monster_type + ".tscn")
	if monster_scene:
		monster = monster_scene.instantiate()
		monster.position = Vector2(200, 0)
		add_child(monster)
		
		# Set monster type
		if monster.has_method("set_type"):
			monster.call("set_type", monster_type)
		else:
			monster.metadata._type = monster_type
			
		# Call _ready on monster
		if monster.has_method("_ready"):
			monster._ready()

func _on_attack_button_pressed():
	if player and monster:
		player.attack(monster)
		if monster.hp > 0:
			monster.attack(player)
		else:
			# Monster defeated
			GameManager.load_overworld()
