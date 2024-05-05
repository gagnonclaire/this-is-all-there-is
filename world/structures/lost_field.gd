extends Node3D

const _LOST_CONTROLLER: PackedScene = preload("res://characters/3_controllers/human_npc_controllers/lost_controller.tscn")

func _on_lost_spawn_timer_timeout() -> void:
	if is_multiplayer_authority():
		#lost_npc_spawn.rpc()
		lost_npc_spawn()

#@rpc("any_peer", "call_local")
func lost_npc_spawn() -> void:
	var random_position: Vector3 = Vector3(randf_range(-25,25), 0, randf_range(-25,25))
	var random_rotation: Vector3 = Vector3(0, randf_range(-2,2), 0)

	var lost_npc: Node = _LOST_CONTROLLER.instantiate()
	add_child(lost_npc, true)
	lost_npc.frame.set_position(position + random_position)
	lost_npc.frame.set_rotation(random_rotation)
	lost_npc.current_destination = position + random_position
