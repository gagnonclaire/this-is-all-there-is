extends RigidBody3D

var examine_text: String = "A Box"
var holding_character: CharacterBody3D = null

func _physics_process(delta):
	if holding_character:
		var destination: Vector3 = holding_character.frame.hold_point.get_global_position()
		var current_position: Vector3 = get_global_position()
		var distance: float = current_position.distance_to(destination)
		var direction: Vector3 = current_position.direction_to(destination)
		var speed: float = distance / delta
		apply_force(direction * speed)

@rpc("any_peer", "call_local")
func pick_up_by(character_name: StringName):
	if MultiplayerControls.is_host:
		holding_character = EventsManager.world_node.get_node(NodePath(character_name))

@rpc("any_peer", "call_local")
func drop():
	if MultiplayerControls.is_host:
		holding_character = null
