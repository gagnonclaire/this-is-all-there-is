# Controller node for player characters
#
# Handles player input and hud

extends Node

# Exposed controller nodes
@onready var hud: CanvasLayer = $HUD
@onready var primary_frame: CharacterBody3D = $HumanFrame
@onready var awaken_cooldown_timer: Timer = $AwakenCooldown
@onready var character_name: String = str("Player ", str(name))

# Controller attributes
var rest_progress: float = 0.0
var is_in_safe_volume: bool = false
var awaken_progress: float = 0.0
var awaken_on_cooldown: bool = false
var sever_range: float = 3.0
var current_frame: CharacterBody3D = null
var current_home: Vector3 = Vector3.ZERO
var current_home_rotation: Vector3 = Vector3.ZERO

#region Controller and default Frame setup
##############################################################################
func _enter_tree() -> void:
	# Called before any children _enter_tree calls
	set_multiplayer_authority(str(name).to_int())

func _ready() -> void:
	current_frame = primary_frame
	current_frame.examine_text = character_name

	if is_multiplayer_authority():
		EventsManager.capture_mouse()
		EventsManager.connect("safe_volume_entered", _on_safe_volume_entered)
		EventsManager.connect("safe_volume_exited", _on_safe_volume_exited)

		current_frame.sever_raycast.set_target_position( \
			Vector3(0, 0, -sever_range))
		current_frame.camera.current = true
		hud.show()
#endregion

#region Control loops
##############################################################################
func _process(delta: float) -> void:
	if is_multiplayer_authority():
		_process_context_indicators()
		_process_awaken(delta)
		_process_rest(delta)
		_process_stamina()

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		_process_movement()
		_move_held_object(delta)

func _unhandled_input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		_process_text_chat()
		_process_babble()
		_process_interact()
		_process_sever()
		_process_grab_and_drop()
		_process_camera_control(event)
#endregion

#region Process loop processors
##############################################################################
func _process_movement() -> void:
	if not current_frame.is_knocked_out \
	and not hud.is_text_chat_open():
		var sprint_mod: float = max(1.0, \
		float(Input.is_action_pressed(KeybindManager.SPRINT)) \
			* current_frame.sprint_speed_modifier)

		var input_dir = \
			Input.get_vector(KeybindManager.LEFT, KeybindManager.RIGHT, KeybindManager.FORWARD, KeybindManager.BACKWARD)
		var direction = (current_frame.transform.basis * \
			Vector3(input_dir.x, 0, input_dir.y)).normalized()

		if direction:
			var new_velocity: Vector3 = current_frame.velocity
			new_velocity.x = direction.x * current_frame.speed * sprint_mod
			new_velocity.z = direction.z * current_frame.speed * sprint_mod

			# Send the movement instructions to the frame authority
			current_frame.set_frame_movement.rpc_id( \
				current_frame.get_multiplayer_authority(), new_velocity)

func _process_awaken(delta: float) -> void:
	if Input.is_action_pressed(KeybindManager.AWAKEN) \
	and _can_awaken():
		awaken_progress = clampf(awaken_progress + (delta * 50.0), 0, 100.0)
	else:
		awaken_progress = clampf(awaken_progress - (delta * 100.0), 0, 100.0)

	hud.modulate_awaken_vignette(awaken_progress / 100.0)

	if awaken_progress == 100.0:
		_awaken()

#TODO Need to pull fade functionality somewhere and make it callable
#TODO by rest and awaken as needed
func _process_rest(delta: float) -> void:
	if Input.is_action_pressed(KeybindManager.REST) \
	and current_frame == primary_frame \
	and is_in_safe_volume \
	and _can_awaken(): #TODO Rename to be generic fade
		rest_progress = clampf(rest_progress + (delta * 50.0), 0, 100.0)
	else:
		rest_progress = clampf(rest_progress - (delta * 100.0), 0, 100.0)

	#hud.modulate_awaken_vignette(rest_progress / 100.0)

	if rest_progress == 100.0:
		current_home = current_frame.get_global_position()
		current_home_rotation = current_frame.get_global_rotation()
		_awaken()

func _process_stamina() -> void:
	hud.modulate_stamina_vignette(1.0 \
		- current_frame.get_current_stamina_percent())
#endregion

#region Text chat
##############################################################################
func _process_text_chat() -> void:
	if Input.is_action_just_pressed(KeybindManager.TALK) \
	and not hud.is_text_chat_open():
		hud.open_text_chat()

	if Input.is_action_just_pressed(KeybindManager.TALK_ENTRY) \
	and hud.is_text_chat_open():
		if hud.get_text_entered():
			current_frame.set_speech_label.rpc(hud.get_text_entered())

		hud.close_text_chat()
#endregion

#region Object grabbing
##############################################################################
func _process_grab_and_drop() -> void:
	_grab_object()
	_drop_object()

func _grab_object() -> void:
	if Input.is_action_just_pressed(KeybindManager.GRAB) \
	and current_frame.interact_raycast.is_colliding() \
	and current_frame.interact_raycast.get_collider().is_in_group("grab_target"):
		current_frame.held_object = current_frame.interact_raycast.get_collider()

func _drop_object() -> void:
	if Input.is_action_just_released(KeybindManager.GRAB) \
	and current_frame.held_object:
		current_frame.held_object.reset_damping.rpc_id(1)
		current_frame.held_object = null

func _move_held_object (delta: float) -> void:
	if current_frame.held_object:
		var destination: Vector3 = current_frame.hold_point.get_global_position()
		var current_position: Vector3 = current_frame.held_object.get_global_position()
		var distance: float = current_position.distance_to(destination)
		var direction: Vector3 = current_position.direction_to(destination)
		var speed: float = clampf(distance / delta, 0.0, 1000.0)
		current_frame.held_object.move_object.rpc_id(1, distance, direction, speed)

func _rotate_held_object(event: InputEvent) -> void:
	if current_frame.held_object \
	and Input.is_action_pressed(KeybindManager.ROTATE):
		var torque: Vector3 = Vector3(event.relative.y, event.relative.x, 0)
		var direction: Vector3 = (current_frame.head_pivot.global_position - current_frame.held_object.global_position)
		var z_view: Vector3 = direction / direction.length()
		var x_view: Vector3 = (Vector3.UP.cross(z_view)) / (Vector3.UP.cross(z_view)).length()
		var y_view: Vector3 = z_view.cross(x_view)
		var rotation_basis: Basis = Basis(x_view, y_view, z_view)
		current_frame.held_object.rotate_object.rpc_id(1, rotation_basis * torque)
#endregion

#region Other processes
##############################################################################
func _process_camera_control(event: InputEvent) -> void:
	if event is InputEventMouseMotion \
	and not current_frame.is_knocked_out \
	and not hud.is_text_chat_open():
		if not (current_frame.held_object and Input.is_action_pressed(KeybindManager.ROTATE)):
			current_frame.rotate_y(-event.relative.x *.005)
			current_frame.head_pivot.rotate_x(-event.relative.y *.005)
			current_frame.head_pivot.rotation.x = clamp( \
			current_frame.head_pivot.rotation.x, -PI / 2.25, PI / 2.25)
		else:
			_rotate_held_object(event) # This probably shouldn't be here...

func _process_interact() -> void:
	if not current_frame.is_knocked_out \
	and not hud.is_text_chat_open():
		if Input.is_action_just_pressed(KeybindManager.INTERACT) \
		and current_frame.interact_raycast.is_colliding() \
		and current_frame.interact_raycast.get_collider(). \
		is_in_group("interact_target"):
			current_frame.interact_raycast.get_collider().interacted_with.rpc()

func _process_sever() -> void:
	if not current_frame.is_knocked_out \
	and not hud.is_text_chat_open():
		if Input.is_action_just_pressed(KeybindManager.SEVER) \
		and current_frame.sever_raycast.is_colliding() \
		and current_frame.sever_raycast.get_collider(). \
		is_in_group("sever_target"):
			sever_to(current_frame.sever_raycast.get_collider())

func _process_babble() -> void:
	if not current_frame.is_knocked_out \
	and not hud.is_text_chat_open():
		if Input.is_action_just_pressed(KeybindManager.BABBLE):
			current_frame.start_speach_audio.rpc(1)
#endregion

#region Rest and Awaken mechanics
##############################################################################
func _can_awaken() -> bool:
	return not (awaken_on_cooldown or hud.is_text_chat_open())

func _awaken() -> void:
	current_frame.camera.current = false
	current_frame = primary_frame
	current_frame.camera.current = true
	current_frame.set_global_position(current_home)
	current_frame.set_global_rotation(current_home_rotation)

	awaken_progress = 100.0
	awaken_on_cooldown = true
	awaken_cooldown_timer.start()

func _on_awaken_cooldown_timeout() -> void:
	awaken_on_cooldown = false

func _on_safe_volume_entered(body: Node3D) -> void:
	if body.get_parent().name.to_int() == get_multiplayer_authority():
		is_in_safe_volume = true
		hud.show_safe_indicator(true)

func _on_safe_volume_exited(body: Node3D) -> void:
	if body.get_parent().name.to_int() == get_multiplayer_authority():
		is_in_safe_volume = false
		hud.show_safe_indicator(false)
#endregion

#region Sever mechanics
##############################################################################
func sever_to(target_frame: CharacterBody3D) -> void:
	current_frame.camera.current = false
	current_frame = target_frame
	current_frame.camera.current = true
	current_frame.sever_raycast.set_target_position( \
		Vector3(0, 0, -sever_range))
#endregion

#region Dynamic Context Indicators
##############################################################################
#TODO Move each check and action into its own function
func _process_context_indicators() -> void:
	if can_check_context_indicators():
		if current_frame.interact_raycast.is_colliding() \
		and current_frame.interact_raycast.get_collider().is_in_group("interact_target"):
			hud.show_interact_context_indicator(true)
		else:
			hud.show_interact_context_indicator(false)

		if current_frame.sever_raycast.is_colliding() \
		and current_frame.sever_raycast.get_collider().is_in_group("sever_target"):
			hud.show_sever_context_indicator(true)
		else:
			hud.show_sever_context_indicator(false)

		# Examine targets use the interact raycast
		if current_frame.interact_raycast.is_colliding() \
		and current_frame.interact_raycast.get_collider().is_in_group("examine_target"):
			hud.show_examine_context_indicator(current_frame.interact_raycast.get_collider().examine_text)
		else:
			hud.show_examine_context_indicator("")

func can_check_context_indicators() -> bool:
	return is_multiplayer_authority() \
	and not current_frame.is_knocked_out \
	and not hud.is_text_chat_open()
#endregion

func interacted_with(caller_id: String) -> void:
	if is_multiplayer_authority():
		var caller_name: String = get_node("../" + caller_id).character_name
		hud.notify_important(caller_name + " is trying to get your attention")
