extends Node

const MAIN_MENU: PackedScene = preload("res://main_menu/main_menu.tscn")
const WORLD: PackedScene = preload("res://world/world_tutorial.tscn")

var main_menu_node: Node
var world_node: Node

var join_address: String = ""
var is_host: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_menu_node = MAIN_MENU.instantiate()
	add_child(main_menu_node)

func load_world() -> void:
	world_node = WORLD.instantiate()
	remove_child(main_menu_node)
	add_child(world_node)

func return_to_menu() -> void:
	main_menu_node = MAIN_MENU.instantiate()
	remove_child(world_node)
	add_child(main_menu_node)
