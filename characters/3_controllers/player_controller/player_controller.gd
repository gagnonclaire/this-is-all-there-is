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
var awaken_progress: float = 0.0
var awaken_on_cooldown: bool = false
var sever_range: float = 3.0
var current_frame: CharacterBody3D = null

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
		_process_wake_up(delta)
		_process_stamina()

func _physics_process(_delta: float) -> void:
	if is_multiplayer_authority():
		_process_movement()

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
		float(Input.is_action_pressed("sprint")) \
			* current_frame.sprint_speed_modifier)

		var input_dir = \
			Input.get_vector("left", "right", "forward", "backward")
		var direction = (current_frame.transform.basis * \
			Vector3(input_dir.x, 0, input_dir.y)).normalized()

		if direction:
			var new_velocity: Vector3 = current_frame.velocity
			new_velocity.x = direction.x * current_frame.speed * sprint_mod
			new_velocity.z = direction.z * current_frame.speed * sprint_mod

			# Send the movement instructions to the frame authority
			current_frame.set_frame_movement.rpc_id( \
				current_frame.get_multiplayer_authority(), new_velocity)

func _process_wake_up(delta: float) -> void:
	if Input.is_action_pressed("awaken") \
	and _can_awaken():
		awaken_progress = clampf(awaken_progress + (delta * 50.0), 0, 100.0)
	else:
		awaken_progress = clampf(awaken_progress - (delta * 100.0), 0, 100.0)

	hud.modulate_awaken_vignette(awaken_progress / 100.0)

	if awaken_progress == 100.0:
		_awaken()

func _process_stamina() -> void:
	hud.modulate_stamina_vignette(1.0 \
		- current_frame.get_current_stamina_percent())
#endregion

#region Input loop processors
##############################################################################
func _process_text_chat() -> void:
	if Input.is_action_just_pressed("talk") \
	and not hud.is_text_chat_open():
		hud.open_text_chat()

	if Input.is_action_just_pressed("talk_entry") \
	and hud.is_text_chat_open():
		if hud.get_text_entered():
			current_frame.set_speech_label.rpc(hud.get_text_entered())

		hud.close_text_chat()

func _process_grab_and_drop() -> void:
	if Input.is_action_just_pressed("grab") \
	and current_frame.interact_raycast.is_colliding() \
	and current_frame.interact_raycast.get_collider().is_in_group("grab_target"):
		current_frame.held_object = current_frame.interact_raycast.get_collider()
		current_frame.held_object.pick_up_by.rpc_id(1, name)

	if Input.is_action_just_released("grab") \
	and current_frame.held_object:
		current_frame.held_object.drop.rpc_id(1)
		current_frame.held_object = null

func _process_camera_control(event: InputEvent) -> void:
	if event is InputEventMouseMotion \
	and not current_frame.is_knocked_out \
	and not hud.is_text_chat_open():
		current_frame.rotate_y(-event.relative.x *.005)
		current_frame.head_pivot.rotate_x(-event.relative.y *.005)
		current_frame.head_pivot.rotation.x = clamp( \
			current_frame.head_pivot.rotation.x, -PI / 2.25, PI / 2.25)

func _process_interact() -> void:
	if not current_frame.is_knocked_out \
	and not hud.is_text_chat_open():
		if Input.is_action_just_pressed("interact") \
		and current_frame.interact_raycast.is_colliding() \
		and current_frame.interact_raycast.get_collider(). \
		is_in_group("interact_target"):
			current_frame.interact_raycast.get_collider().interacted_with.rpc()

func _process_sever() -> void:
	if not current_frame.is_knocked_out \
	and not hud.is_text_chat_open():
		if Input.is_action_just_pressed("sever") \
		and current_frame.sever_raycast.is_colliding() \
		and current_frame.sever_raycast.get_collider(). \
		is_in_group("sever_target"):
			sever_to(current_frame.sever_raycast.get_collider())

func _process_babble() -> void:
	if not current_frame.is_knocked_out \
	and not hud.is_text_chat_open():
		if Input.is_action_just_pressed("babble"):
			current_frame.start_speach_audio.rpc(1)
#endregion

#region Awaken mechanics
##############################################################################
func _can_awaken() -> bool:
	return not (awaken_on_cooldown or hud.is_text_chat_open())

func _awaken() -> void:
	current_frame = primary_frame
	current_frame.set_global_position(Vector3.ZERO)
	current_frame.set_global_rotation(Vector3.ZERO)

	awaken_progress = 100.0
	awaken_on_cooldown = true
	awaken_cooldown_timer.start()

func _on_awaken_cooldown_timeout() -> void:
	awaken_on_cooldown = false
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

#TODO MOVE THIS HOLY SHIT
@rpc("any_peer", "call_local")
func debug_spawn() -> void:
	var random_position: Vector3 = Vector3(randf_range(-50,50), 0, randf_range(-50,50))
	var random_rotation: Vector3 = Vector3(0, randf_range(-50,50), 0)
	EventsManager.debug_spawn(random_position, random_rotation)
