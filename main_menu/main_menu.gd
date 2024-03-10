extends Node

@onready var main_node: Node = get_parent()
@onready var address_entry: LineEdit = $CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/AddressEntry

func _on_new_game_button_pressed():
	main_node.is_host = true
	main_node.load_world()

func _on_load_game_button_pressed():
	main_node.is_host = true
	main_node.load_world()

func _on_join_game_button_pressed():
	main_node.is_host = false
	main_node.join_address = address_entry.text
	main_node.load_world()

func _on_exit_button_pressed():
	get_tree().quit()
