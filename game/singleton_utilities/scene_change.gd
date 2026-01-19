extends Node

const MAIN_MENU: PackedScene = preload("res://game/ui/menus/main_menu/main_menu.tscn")
const MAIN_WORLD: PackedScene = preload("res://game/world/main_world.tscn")
const BOARD_EDITOR: PackedScene = preload("res://game/board_editor/board_editor.tscn")

@onready var _main_node: Node = get_node("/root/Main")

func switch_to_main_menu() -> void:
	_unload_main_children()
	_load_main_menu()

func switch_to_main_world() -> void:
	_unload_main_children()
	_load_main_world()

func switch_to_board_creator(board_name) -> void:
	_unload_main_children()
	_load_board_creator(board_name)

func _load_main_menu() -> void:
	_main_node.add_child(MAIN_MENU.instantiate())

func _load_main_world() -> void:
	_main_node.add_child(MAIN_WORLD.instantiate())

func _load_board_creator(board_name: StringName) -> void:
	var board_editor: BoardEditor = BOARD_EDITOR.instantiate()
	board_editor.board_name = board_name
	_main_node.add_child(BOARD_EDITOR.instantiate())

func _unload_main_children() -> void:
	for child in _main_node.get_children():
		child.queue_free()
