class_name NewGameMenu
extends PanelContainer

@onready var new_game_entry: LineEdit = $HBoxContainer/GameNameEntry

func _on_start_game_button_pressed() -> void:
	#TODO check save games for a game with that name
	#TODO if none exist, create new one
	#TODO otherwise, show error text and do nothing
	#join_address = address_entry.text

	MultiplayerManager.start_server()
	SceneChange.switch_to_main_world()
