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
	MultiplayerControls.is_host = true
	MultiplayerControls.port = PORT

	add_world_node()

func join_multiplayer_world() -> void:
	MultiplayerControls.port = PORT
	MultiplayerControls.join_address = join_address

	add_world_node()

func add_world_node() -> void:
	world_node = WORLD.instantiate()
	add_child(world_node)
	EventsManager.world_node = world_node

	EventsManager.capture_mouse()
	main_menu_node.queue_free()

func return_to_menu() -> void:
	main_menu_node = MAIN_MENU.instantiate()
	EventsManager.free_mouse()
	world_node.queue_free()
	add_child(main_menu_node)
