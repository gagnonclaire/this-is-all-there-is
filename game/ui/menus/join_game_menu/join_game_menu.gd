class_name JoinGameMenu
extends PanelContainer

@onready var address_entry: LineEdit = $VBoxContainer/MarginContainer/AddressEntry

func _on_join_game_button_pressed() -> void:
	MultiplayerManager.start_client(address_entry.text)
	SceneChange.switch_to_main_world()
