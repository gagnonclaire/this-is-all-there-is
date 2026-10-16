class_name GameListItem
extends HBoxContainer

signal start_game_world(game_name: String)
signal start_host_game_world(game_name: String)

@onready var game_name_label: Label = $GameName

var game_name: String

func _ready():
	game_name_label.text = game_name

func _on_load_game_button_pressed():
	start_game_world.emit(game_name)

func _on_load_host_game_button_pressed():
	start_host_game_world.emit(game_name)

func _on_delete_game_button_pressed():
	GameSaveLoad.delete_game(game_name)
	get_parent().remove_child(self)
	queue_free()
