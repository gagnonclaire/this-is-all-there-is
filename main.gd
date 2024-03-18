extends Node

const MAIN_MENU: PackedScene = preload("res://main_menu/main_menu.tscn")
const WORLD: PackedScene = preload("res://worlds/tutorial/world_tutorial.tscn")

const PORT: int = 9999

var main_menu_node: Node
var world_node: Node

var join_address: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_menu_node = MAIN_MENU.instantiate()
	add_child(main_menu_node)

func host_multiplayer_world() -> void:
	add_world_node(true)

func join_multiplayer_world() -> void:
	add_world_node(false)

func add_world_node(is_host: bool) -> void:
	world_node = WORLD.instantiate()
	world_node.is_host = is_host
	world_node.port = PORT
	world_node.join_address = join_address

	capture_mouse()
	main_menu_node.queue_free()
	add_child(world_node)

func return_to_menu() -> void:
	main_menu_node = MAIN_MENU.instantiate()
	free_mouse()
	world_node.queue_free()
	add_child(main_menu_node)

#region Mouse Capture Controls
func capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func free_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
#endregion
