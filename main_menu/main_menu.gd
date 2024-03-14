extends Node

const MENU_SCENE_1: PackedScene = preload("res://main_menu/scene/menu_scene_1.tscn")

@onready var main_node: Node = get_parent()
@onready var sub_menus: Control = $CanvasLayer/TopMenu/SubMenus

@onready var  load_game_menu: Control = $CanvasLayer/TopMenu/SubMenus/LoadGameMenu
@onready var join_game_menu: Control = $CanvasLayer/TopMenu/SubMenus/JoinGameMenu
@onready var settings_menu: Control = $CanvasLayer/TopMenu/SubMenus/SettingsMenu

# This shouldn't even be handled here
@onready var address_entry: LineEdit = $CanvasLayer/TopMenu/SubMenus/JoinGameMenu/Panel/VBoxContainer/MarginContainer/AddressEntry

func _ready() -> void:
	add_child(MENU_SCENE_1.instantiate())

	# Close server
	multiplayer.multiplayer_peer = null

func _unhandled_input(_event) -> void:
	if Input.is_action_just_pressed("menu"):
		get_tree().quit()

func _on_new_game_button_pressed() -> void:
	close_all_menus()
	main_node.is_host = true
	print("Hosting new game on port 9999")
	main_node.load_world()

func _on_load_game_button_pressed() -> void:
	switch_to(load_game_menu)

#region Join Game
func _on_join_game_button_pressed() -> void:
	switch_to(join_game_menu)

func _on_join_button_pressed() -> void:
	main_node.is_host = false
	main_node.join_address = address_entry.text

	print("Joining game at ", main_node.join_address, ":9999")
	main_node.load_world()
#endregion

func _on_settings_button_pressed() -> void:
	switch_to(settings_menu)

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func switch_to(item: Node) -> void:
	var menus: Array[Node] = sub_menus.get_children()
	item.set_visible(not item.is_visible())

	for menu in menus:
		if menu != item:
			menu.hide()

func close_all_menus() -> void:
	for menu in sub_menus.get_children():
		menu.hide()
