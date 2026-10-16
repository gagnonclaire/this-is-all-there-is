class_name JoinGameMenu
extends PanelContainer

signal join_game(address: String)

@onready var address_entry: LineEdit = $VBoxContainer/MarginContainer/AddressEntry

func _on_join_game_button_pressed():
	join_game.emit(address_entry.text)
