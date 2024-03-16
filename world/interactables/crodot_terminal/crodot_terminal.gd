extends StaticBody3D

@onready var display: Label3D = $CrodotsDisplay


func _process(_delta):
	if display:
		# Current crodots is a var stored in the world
		display.set_text(str(get_tree().get_first_node_in_group("world").crodots))

@rpc("any_peer", "call_local")
func interacted_with():
	if is_multiplayer_authority():
		Events.emit_signal("crodots_gained", 1)
