extends Node

signal crodots_gained(amount: int)
signal crodots_lost(amount: int)

var world_node: Node

#region Mouse Capture Controls
func capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func free_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
#endregion
