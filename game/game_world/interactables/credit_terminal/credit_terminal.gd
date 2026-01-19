extends StaticBody3D

@onready var display: Label3D = $CreditsDisplay


func _process(_delta):
	if display:
		# Current credits is a var stored in the world
		display.set_text(str(get_tree().get_first_node_in_group("world").credits))

@rpc("any_peer", "call_local")
func interacted_with():
	if is_multiplayer_authority():
		EventsManager.emit_signal("credits_gained", 1)
