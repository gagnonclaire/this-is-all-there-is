extends Node

const MAIN_MENU: PackedScene = preload("res://main_menu/main_menu.tscn")
const WORLD: PackedScene = preload("res://world/world_tutorial.tscn")

@onready var main_menu_node: Node = MAIN_MENU.instantiate()
@onready var world_node: Node = WORLD.instantiate()

var join_address: String = ""
var is_host: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(main_menu_node)

func _unhandled_input(_event):
	if Input.is_action_just_pressed("menu"):
		get_tree().quit()

func load_world():
	remove_child(main_menu_node)
	add_child(world_node)
