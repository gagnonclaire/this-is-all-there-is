extends Node3D

const LIGHT_NODE: PackedScene = preload("res://world/interactables/light/light.tscn")

@rpc("any_peer", "call_local")
func interacted_with():
	if is_multiplayer_authority():
		EventsManager.emit_signal("credits_lost", 5)
		var new_light: RigidBody3D = LIGHT_NODE.instantiate()
		new_light.position = Vector3(0, 0, 1)
		add_child(new_light, true)
