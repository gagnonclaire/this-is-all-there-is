class_name GameListItem
extends HBoxContainer

@onready var game_name_label: Label = $GameName

var game_name: String

func _ready() -> void:
	game_name_label.text = game_name

func _on_load_game_button_pressed() -> void:
	SceneChange.switch_to_start_game_world(game_name, false)

func _on_load_host_game_button_pressed():
	SceneChange.switch_to_start_game_world(game_name, true)

func _on_delete_game_button_pressed():
	GameSaveLoad.delete_game(game_name)
	get_parent().remove_child(self)
	queue_free()
