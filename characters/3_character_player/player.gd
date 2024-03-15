extends CharacterBody3D

const SPEED: float = 5.0
const SPRINT_MODIFIER: float = 3.0
const MAX_STAMINA: float = 100.0
const STAMINA_DRAIN_MODIFIER_SPRINT: float = 10.0
const STAMINA_DRAIN_MODIFIER_SEVER: float = 10.0
const STAMINA_DRAIN_MODIFIER_SEVER_CONTROL: float = 10.0
const STAMINA_GAIN_MODIFIER_BASE: float = 5.0
const STAMINA_GAIN_MODIFIER_OUT: float = 15.0

const SEVER_RANGE: float = 3.0

@onready var hud: CanvasLayer = $HUD
@onready var world_collision: CollisionShape3D = $WorldCollider
@onready var sever_cooldown_timer: Timer = $SeverCooldown
@onready var wake_up_cooldown_timer: Timer = $WakeUpCooldown
@onready var frame: Node3D = $HumanFrame

@onready var world_node: Node = get_parent()
@onready var main_node: Node = world_node.get_parent()

var current_stamina: float = MAX_STAMINA
var wake_progress: float = 0.0
var current_body: Object = self

var is_knocked_out: bool = false
var is_severed: bool = false
var can_sever: bool = true
var can_wake_up: bool = true

# Eventually these names will be custom or procedural, this is placeholder
var character_name: String = "A Player"

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#region Overrides
func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

func _ready() -> void:
	frame.stamina_drain_multiplier = 2.0

	if is_multiplayer_authority():
		frame.sever_raycast.set_target_position(Vector3(0, 0, -SEVER_RANGE))
		hud.show()
		frame.camera.current = true

func _process(delta: float) -> void:
	if is_multiplayer_authority():
		# Wake up
		if Input.is_action_pressed("wake_up") \
		and can_wake_up \
		and not is_knocked_out \
		and not hud.text_chat_entry.is_visible():
			wake_progress = clampf(wake_progress + (delta * 50.0), 0, 100.0)
		else:
			wake_progress = clampf(wake_progress - (delta * 100.0), 0, 100.0)

		hud.unstuck_vignette.set_modulate(Color(1, 1, 1, (wake_progress / 100.0)))

		if wake_progress == 100.0:
			wake_up()

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		if not is_on_floor():
			velocity.y -= gravity * delta

		do_stamina_change(delta)
		do_knockout_check()

		# Basic movement, starts with slowdown
		velocity.x = move_toward(velocity.x, 0, SPEED / 5)
		velocity.z = move_toward(velocity.z, 0, SPEED / 5)

		if not hud.text_chat_entry.is_visible() \
		and (not is_severed or Input.is_action_pressed("control_self")):
			# Sprint modifier
			var current_sprint_mod: float = 1.0
			if Input.is_action_pressed("sprint") and not is_knocked_out:
				current_sprint_mod = SPRINT_MODIFIER

			var input_dir = Input.get_vector("left", "right", "forward", "backward")
			var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

			if direction:
				velocity.x = direction.x * SPEED * current_sprint_mod
				velocity.z = direction.z * SPEED * current_sprint_mod

		move_and_slide()

#TODO fix me please i am so bad
func _unhandled_key_input(_event):
	if is_multiplayer_authority() \
	and not is_knocked_out \
	and not hud.text_chat_entry.is_visible():
		# Interact Raycast events
		if Input.is_action_just_pressed("interact") \
		and (not is_severed or Input.is_action_pressed("control_self")) \
		and frame.interact_raycast.is_colliding():
			var interact_target: Object = frame.interact_raycast.get_collider()
			if interact_target.is_in_group("interact_raycast_target") \
			and interact_target.is_in_group("player"):
				interact_target.interacted_with.rpc_id(interact_target.name.to_int())
			elif interact_target.is_in_group("interact_raycast_target"):
				interact_target.interacted_with.rpc()

		# Sever Raycast events
		if Input.is_action_just_pressed("sever") \
		and can_sever \
		and current_body.frame.sever_raycast.is_colliding() \
		and current_body.frame.sever_raycast.get_collider().is_in_group("sever_raycast_target"):
			sever_to(current_body.frame.sever_raycast.get_collider())

		# Talk via text chat
		if Input.is_action_just_pressed("talk") \
		and not is_severed:
			if not hud.text_chat_entry.is_visible():
				main_node.free_mouse()
				hud.text_chat_entry.show()
				hud.text_chat_entry.grab_focus()

		# Generic speech
		if Input.is_action_just_pressed("babble") \
		and (not is_severed or Input.is_action_pressed("control_self")) \
		and not is_knocked_out:
			frame.start_speach_audio.rpc(1)

		# Debug events
		if Input.is_action_just_pressed("debug_spawn"):
			rpc_id(1, "debug_spawn")

# Handles severed and unsevered camera movement
# Need some way to toggle between these two while severd
func _unhandled_input(event):
	if is_multiplayer_authority() \
	and event is InputEventMouseMotion \
	and not is_knocked_out \
	and not hud.text_chat_entry.is_visible():
		if is_severed and not Input.is_action_pressed("control_self"):
			current_body.frame.sever_camera.rotate_y(-event.relative.x *.005)
			current_body.frame.sever_camera.rotation.y = clampf(current_body.frame.sever_camera.rotation.y, -PI / 4.5, PI / 4.5)
			current_body.frame.sever_camera.rotate_x(-event.relative.y *.005)
			current_body.frame.sever_camera.rotation.x = clampf(current_body.frame.sever_camera.rotation.x, -PI / 4.5, PI / 4.5)
			current_body.frame.sever_camera.rotation.z = 0
			print(current_body.frame.sever_camera.get_rotation())
		else:
			rotate_y(-event.relative.x *.005)
			frame.camera_pivot.rotate_x(-event.relative.y *.005)
			frame.camera_pivot.rotation.x = clamp(frame.camera_pivot.rotation.x, -PI / 2.25, PI / 2.25)
#endregion

#region Signal Callbacks
func _on_sever_cooldown_timeout():
	can_sever = true

func _on_wake_up_cooldown_timeout():
	can_wake_up = true
#endregion

#region Action Functions
func do_stamina_change(delta: float):
	var stamina_change = delta * STAMINA_GAIN_MODIFIER_BASE

	if Input.is_action_pressed("control_self") \
	and not is_knocked_out \
	and is_severed:
		stamina_change -= delta * STAMINA_DRAIN_MODIFIER_SEVER_CONTROL

	if Input.is_action_pressed("sprint") \
	and not is_knocked_out:
		stamina_change -= delta * STAMINA_DRAIN_MODIFIER_SPRINT

	if is_severed:
		stamina_change -= delta * STAMINA_DRAIN_MODIFIER_SEVER * current_body.frame.stamina_drain_multiplier

	if is_knocked_out:
		stamina_change = delta * STAMINA_GAIN_MODIFIER_OUT

	current_stamina = clampf(current_stamina + stamina_change, 0, MAX_STAMINA)
	hud.stamina_vignette.set_modulate(Color(1, 1, 1, 1 - (current_stamina / MAX_STAMINA)))

func do_knockout_check():
	if current_stamina == 0 and not is_knocked_out:
		do_knockout()
	elif is_knocked_out and current_stamina == MAX_STAMINA:
		do_un_knockout()

func do_knockout():
	if is_severed:
		un_sever()
	is_knocked_out = true

	frame.start_ragdoll.rpc()
	world_collision.set_disabled(true)

func do_un_knockout():
	# Get core bone so we can update new world position
	var bone_position: Vector3 = frame.core_bone.get_global_position()

	frame.stop_ragdoll.rpc()
	set_global_position(bone_position)
	world_collision.set_disabled(false)
	is_knocked_out = false

func sever_to(target: Object):
	if target == self:
		un_sever()
	else:
		# When in your own obdy you use your main camera to sever
		if is_severed:
			current_body.frame.sever_camera.current = false
		else:
			current_body.frame.camera.current = false

		target.frame.sever_camera.current = true
		target.frame.sever_raycast.set_target_position(Vector3(0, 0, -SEVER_RANGE))

		is_severed = true
		current_body = target

		can_sever = false
		sever_cooldown_timer.start()

func un_sever():
	current_body.frame.sever_camera.current = false
	frame.camera.current = true

	is_severed = false
	current_body = self

	can_sever = false
	sever_cooldown_timer.start()

func wake_up():
	if is_severed:
		un_sever()
	set_global_position(Vector3.ZERO)
	current_stamina = MAX_STAMINA
	can_wake_up = false
	wake_up_cooldown_timer.start()

func send_message(message: String):
	if message.length() > 0:
		frame.set_speech_label.rpc(message)

	main_node.capture_mouse()
	hud.text_chat_entry.hide()
#endregion

#region RPCs
@rpc("any_peer")
func interacted_with():
	# Will need to be more clever if interacting via sever is allowed
	var caller_id: String = str(multiplayer.get_remote_sender_id())
	var caller_name: String = get_node("../" + caller_id).character_name
	hud.notify_important(caller_name + " is trying to get your attention")

@rpc("any_peer", "call_local")
func debug_spawn():
	var random_position: Vector3 = Vector3(randf_range(-50,50), 0, randf_range(-50,50))
	var random_rotation: Vector3 = Vector3(0, randf_range(-50,50), 0)
	world_node.debug_spawn(random_position, random_rotation)
#endregion



