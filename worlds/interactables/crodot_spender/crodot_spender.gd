extends Node3D

@rpc("any_peer", "call_local")
func interacted_with():
	if is_multiplayer_authority():
		EventsManager.emit_signal("crodots_lost", 1)
