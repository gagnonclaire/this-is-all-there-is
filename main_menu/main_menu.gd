# Main menu node, acts as the first functional startup node
#
# All TopMenu buttons open submenus which handle the logic for accessing
# settings, creating new world, loading saved worlds, and joining worlds
#
# Mostly leaves logic, including singelton interfacing, to its various sub
# menu nodes so it can focus on menu control

extends Node

const MENU_SCENE_ROADSIDE: PackedScene = preload("res://main_menu/scenes/roadside_scene/roadside.tscn")

@onready var sub_menus: Control = $CanvasLayer/TopMenu/SubMenus
@onready var load_game_menu: Control = $CanvasLayer/TopMenu/SubMenus/LoadGameMenu
@onready var join_game_menu: Control = $CanvasLayer/TopMenu/SubMenus/JoinGameMenu
@onready var settings_menu: Control = $CanvasLayer/TopMenu/SubMenus/SettingsMenu

#TODO move this into the join game menu scene when that exists
@onready var address_entry: LineEdit = $CanvasLayer/TopMenu/SubMenus/JoinGameMenu/Panel/VBoxContainer/MarginContainer/AddressEntry

#TODO Clean this stuff up pls, should only be menu controls here
func _ready() -> void:
	add_child(MENU_SCENE_ROADSIDE.instantiate())
	EventsManager.free_mouse()

func _unhandled_input(_event) -> void:
	if Input.is_action_just_pressed("menu"):
		get_tree().quit()

func _on_new_game_button_pressed() -> void:
	_close_all_menus()
	MultiplayerManager.is_host = true
	LoadManager.switch_to_main_world()

func _on_load_game_button_pressed() -> void:
	_switch_to_menu(load_game_menu)

func _on_join_game_button_pressed() -> void:
	_switch_to_menu(join_game_menu)

func _on_join_button_pressed() -> void:
	_close_all_menus()
	MultiplayerManager.join_address = address_entry.text
	LoadManager.switch_to_main_world()

func _on_settings_button_pressed() -> void:
	_switch_to_menu(settings_menu)

func _on_exit_button_pressed() -> void:
	get_tree().quit()

#region Menu Management helpers
func _switch_to_menu(item: Node) -> void:
	var menus: Array[Node] = sub_menus.get_children()
	item.set_visible(not item.is_visible())

	for menu in menus:
		if menu != item:
			menu.hide()

func _close_all_menus() -> void:
	for menu in sub_menus.get_children():
		menu.hide()
#endregion
