extends Node

const MENU_SCENE_1: PackedScene = preload("res://main_menu/menu_scene_1.tscn")

@onready var main_node: Node = get_parent()

@onready var address_entry: LineEdit = $CanvasLayer/JoinGameMenu/Panel/VBoxContainer/MarginContainer/AddressEntry
@onready var join_game_menu: Control = $CanvasLayer/JoinGameMenu

func _ready():
	# Load a random menu scene
	add_child(MENU_SCENE_1.instantiate())

func _on_new_game_button_pressed():
	main_node.is_host = true
	main_node.load_world()

func _on_load_game_button_pressed():
	pass

func _on_join_game_button_pressed():
	join_game_menu.show()

func _on_join_button_pressed():
	main_node.is_host = false
	main_node.join_address = address_entry.text

	print("Joining game at ", main_node.join_address, ":9999")
	main_node.load_world()

func _on_exit_button_pressed():
	get_tree().quit()
