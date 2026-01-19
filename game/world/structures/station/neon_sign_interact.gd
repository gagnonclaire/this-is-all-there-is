extends StaticBody3D

@onready var sign_node: NeonSign = $"../.."

@rpc("any_peer", "call_local")
func interacted_with():
	if is_multiplayer_authority():
		sign_node.show_editor()
