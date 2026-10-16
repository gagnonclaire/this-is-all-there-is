class_name InteractingCamera
extends BaseCamera

@onready var interacting_raycast: RayCast3D = $InteractingRayCast

func _unhandled_input(event: InputEvent):
	if not is_multiplayer_authority():
		return

	if event.is_action_pressed(Keybinds.INTERACT):
		interact_with_target()

func interact_with_target():
	# Should type to the base interact target class when that's implemented
	var target: Node = interacting_raycast.get_collider()

	if target and target.is_in_group(Constants.GROUP_INTERACT_TARGET):
		target.interacted_with()
