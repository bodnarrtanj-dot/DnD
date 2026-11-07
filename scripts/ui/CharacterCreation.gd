extends Control

@onready var name_input: LineEdit = $FormContainer/NameInput
@onready var class_selector: OptionButton = $FormContainer/ClassSelector
@onready var stats_label: Label = $FormContainer/StatsDisplay
@onready var confirm_btn: Button = $FormContainer/ConfirmButton
@onready var back_btn: Button = $FormContainer/BackButton

var selected_class: String = "Воїн"

func _ready():
	class_selector.add_item("Воїн")
	class_selector.add_item("Маг")
	class_selector.add_item("Слідопит")
	class_selector.add_item("Клерик")
	class_selector.item_selected = 0
	confirm_btn.pressed.connect(_on_confirm)
	back_btn.pressed.connect(_on_back)
	class_selector.item_selected.connect(_on_class_selected)
	_update_stats()

func _on_class_selected(index: int):
	var classes = ["Воїн", "Маг", "Слідопит", "Клерик"]
	selected_class = classes[index]
	_update_stats()

func _update_stats():
	var stats = {
		"Воїн": "СИЛ 16, ДІВ 14, КОН 16, HP 10",
		"Маг": "ІНТ 16, ДІВ 14, КОН 10, HP 6, MP 10",
		"Слідопит": "ДІВ 16, Муд 14, КОН 14, HP 8",
		"Клерик": "Муд 16, КОН 14, Хар 12, HP 8"
	}
	stats_label.text = stats[selected_class]

func _on_confirm():
	if name_input.text.is_empty():
		return
	var player_scene = preload("res://scenes/entities/player.tscn")
	var player = player_scene.instantiate()
	player.display_name = name_input.text
	player.class_name_val = selected_class
	player._ready()
	GameManager.current_player = player
	GameManager.add_player(player)
	get_tree().change_scene_to_file("res://scenes/world/prolog.tscn")

func _on_back():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
