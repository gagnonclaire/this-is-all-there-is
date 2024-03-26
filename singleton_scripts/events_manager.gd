extends Node

signal crodots_gained(amount: int)
signal crodots_lost(amount: int)

signal safe_volume_entered()
signal safe_volume_exited()

const WORLD_PATH: String = "/root/Main/MainWorld/"

#region Mouse Capture Controls
func capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func free_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
#endregion

#TODO Find a more robust way to get this node
#TODO Main issue is we just assume there is a world at this point and
#TODO that the character is a direct child of it
func get_player_controller(controller_name: StringName) -> Node:
	return get_node(NodePath(str(WORLD_PATH, controller_name)))

#TODO Hate how this is relying on the world node to have this functionality
#TODO Maybe once I move away from debug controls it will get better
func debug_spawn(position: Vector3, rotation: Vector3) -> void:
	var world: Node = get_node(NodePath(WORLD_PATH))
	world.debug_spawn(position, rotation)
