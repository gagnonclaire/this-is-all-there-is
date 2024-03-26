extends Node

const _MAIN_MENU: PackedScene = preload("res://main_menu/main_menu.tscn")
const _MAIN_WORLD: PackedScene = preload("res://world/main_world.tscn")

@onready var _main_node: Node = get_node("/root/Main")

#region Manager controls
func show_main_menu() -> void:
	_load_main_menu()

func switch_to_main_menu() -> void:
	_unload_main_children()
	_load_main_menu()

func switch_to_main_world() -> void:
	_unload_main_children()
	_load_main_world()
#endregion

#region Loading and Unloading helpers
func _load_main_menu() -> void:
	_main_node.add_child(_MAIN_MENU.instantiate())

func _load_main_world() -> void:
	_main_node.add_child(_MAIN_WORLD.instantiate())

func _unload_main_children() -> void:
	for child in _main_node.get_children():
		child.queue_free()
#endregion
