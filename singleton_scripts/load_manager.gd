extends Node

const _MAIN_MENU: PackedScene = preload("res://main_menu/main_menu.tscn")
const _MAIN_WORLD: PackedScene = preload("res://world/main_world.tscn")
const _BOARD_CREATOR: PackedScene = preload("res://game/board_creator/board_creator.tscn")

@onready var _main_node: Node = get_node("/root/Main")
func switch_to_main_menu() -> void:
	_unload_main_children()
	_load_main_menu()

func switch_to_main_world() -> void:
	_unload_main_children()
	_load_main_world()

func switch_to_board_creator() -> void:
	_unload_main_children()
	_load_board_creator()

func _load_main_menu() -> void:
	_main_node.add_child(_MAIN_MENU.instantiate())

func _load_main_world() -> void:
	_main_node.add_child(_MAIN_WORLD.instantiate())

func _load_board_creator() -> void:
	_main_node.add_child(_BOARD_CREATOR.instantiate())

func _unload_main_children() -> void:
	for child in _main_node.get_children():
		child.queue_free()
