extends Node

#signal credits_gained(amount: int)
#signal credits_lost(amount: int)
#
#signal safe_volume_entered()
#signal safe_volume_exited()

const WORLD_PATH: String = "/root/Main/MainWorld/"

func capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func free_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func toggle_mouse() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		free_mouse()
	else:
		capture_mouse()

func is_mouse_captured() -> bool:
	return Input.mouse_mode ==Input.MOUSE_MODE_CAPTURED

#TODO Find a more robust way to get this node
#TODO Main issue is we just assume there is a world at this point and
#TODO that the character is a direct child of it
func get_player_controller(controller_name: StringName) -> Node:
	return get_node(NodePath(str(WORLD_PATH, controller_name)))
