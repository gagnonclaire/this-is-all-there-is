extends Node

const MAIN_MENU: PackedScene = preload("res://main_menu/main_menu.tscn")
const WORLD: PackedScene = preload("res://world/world.tscn")

var main_menu_node: Node
var world_node: Node

var join_address: String
var is_host: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	main_menu_node = MAIN_MENU.instantiate()
	world_node = WORLD.instantiate()
	add_child(main_menu_node)

func _unhandled_input(_event):
	if Input.is_action_just_pressed("menu"):
		get_tree().quit()

func load_world():
	remove_child(main_menu_node)
	add_child(world_node)
