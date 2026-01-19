class_name JoinGameMenu
extends PanelContainer

@onready var address_entry: LineEdit = $VBoxContainer/MarginContainer/AddressEntry

func _on_join_game_button_pressed() -> void:
	SceneChange.switch_to_join_game_world(address_entry.text)
