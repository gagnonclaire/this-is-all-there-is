extends Node3D

const MOVEABLE_WALL_NODE: PackedScene = preload("res://world/interactables/moveable_wall/moveable_wall.tscn")

@rpc("any_peer", "call_local")
func interacted_with():
	if is_multiplayer_authority():
		EventsManager.emit_signal("credits_lost", 5)
		var new_moveable_wall: MoveableObject = MOVEABLE_WALL_NODE.instantiate()
		new_moveable_wall.position = Vector3(0, 0, 1)
		add_child(new_moveable_wall, true)
