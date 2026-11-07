extends Control

@onready var next_btn: Button = $NextButton

func _ready():
	next_btn.pressed.connect(_on_next)

func _on_next():
	get_tree().change_scene_to_file("res://scenes/world/overworld.tscn")
