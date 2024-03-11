extends CharacterBody3D

const SPEED: float = 5.0
const SPRINT_MODIFIER: float = 3.0
const MAX_STAMINA: float = 100.0
const STAMINA_DRAIN_MODIFIER_SPRINT: float = 25.0
const STAMINA_DRAIN_MODIFIER_SEVER: float = 25.0
const STAMINA_GAIN_MODIFIER_BASE: float = 5.0
const STAMINA_GAIN_MODIFIER_OUT: float = 15.0

@onready var hud: CanvasLayer = $HUD
@onready var physics_collision: CollisionShape3D = $PhysicsCollider
@onready var sever_cooldown_timer: Timer = $SeverCooldown
@onready var frame: Node3D = $HumanFrame

@onready var world_node: Node = get_parent()
@onready var main_node: Node = world_node.get_parent()

@onready var current_stamina: float = MAX_STAMINA
@onready var unstuck_progress: float = 0.0
@onready var sever_target: Object = null

@onready var is_knocked_out: bool = false
@onready var is_severed: bool = false

@onready var can_switch_cameras: bool = true

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


#region Overrides
func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if is_multiplayer_authority():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		hud.show()

		frame.camera.current = true

func _physics_process(delta: float):
	if is_multiplayer_authority():
		# Add gravity
		if not is_on_floor():
			velocity.y -= gravity * delta

		do_stamina_change(delta)
		do_knockout()

		# Unstuck mechanic, want this to be blocked when knocked out
		if Input.is_action_pressed("unstuck"):
			unstuck_progress = clampf(unstuck_progress + (delta * 50.0), 0, 100.0)
		else:
			unstuck_progress = clampf(unstuck_progress - (delta * 100.0), 0, 100.0)

		hud.unstuck_vignette.set_modulate(Color(1, 1, 1, (unstuck_progress / 100.0)))

		if unstuck_progress == 100.0:
			rpc("unstuck")

		# Basic movement
		var current_sprint_mod: float = 1.0
		if Input.is_action_pressed("sprint") and not is_knocked_out:
			current_sprint_mod = SPRINT_MODIFIER
		var input_dir = Input.get_vector("left", "right", "forward", "backward")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED * current_sprint_mod
			velocity.z = direction.z * SPEED * current_sprint_mod
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * current_sprint_mod)
			velocity.z = move_toward(velocity.z, 0, SPEED * current_sprint_mod)

		move_and_slide()

func _unhandled_key_input(event):
	if is_multiplayer_authority() and not is_knocked_out:
		# Short Raycast events
		if frame.short_raycast.is_colliding() \
		and frame.short_raycast.get_collider().is_in_group("short_raycast_target"):
			do_short_raycast_events(frame.short_raycast.get_collider())

		# Other events
		if Input.is_action_just_pressed("debug_spawn") and main_node.is_host:
			var random_position: Vector3 = Vector3(randf_range(-50,50), 0, randf_range(-50,50))
			var random_rotation: Vector3 = Vector3(0, randf_range(-50,50), 0)
			world_node.debug_spawn(random_position, random_rotation)

		if Input.is_action_just_pressed("change_camera") \
		and is_severed \
		and can_switch_cameras:
			reset_camera()

		if Input.is_action_just_pressed("debug_camera"):
			world_node.toggle_debug_camera()

func _unhandled_input(event):
	if is_multiplayer_authority() and not is_knocked_out:
		# Camera movement
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x *.005)
			frame.camera.rotate_x(-event.relative.y *.005)
			frame.camera.rotation.x = clamp(frame.camera.rotation.x, -PI/2, PI/2)
#endregion

#region Signal Callbacks
func _on_sever_cooldown_timeout():
	can_switch_cameras = true
#endregion

#region Do Functions
func do_stamina_change(delta: float):
	var stamina_change = 0

	if Input.is_action_pressed("sprint") \
	and not is_severed and not is_knocked_out:
		stamina_change -= delta * STAMINA_DRAIN_MODIFIER_SPRINT

	if is_severed:
		stamina_change -= delta * STAMINA_DRAIN_MODIFIER_SEVER

	if is_knocked_out:
		stamina_change = delta * STAMINA_GAIN_MODIFIER_OUT

	# Always add base regen
	stamina_change += delta * STAMINA_GAIN_MODIFIER_BASE

	current_stamina = clampf(current_stamina + stamina_change, 0, MAX_STAMINA)
	hud.stamina_vignette.set_modulate(Color(1, 1, 1, 1 - (current_stamina / MAX_STAMINA)))

func do_knockout():
	# Check knockout state, prevent movement
	if current_stamina == 0 and not is_knocked_out:
		if is_severed:
			reset_camera()
		is_knocked_out = true
		rpc("start_ragdoll")
	elif is_knocked_out and current_stamina == MAX_STAMINA:
		is_knocked_out = false
		rpc("stop_ragdoll")

func do_short_raycast_events(target: Object):
	if Input.is_action_just_pressed("interact") \
	and target.is_in_group("interactable"):
		target.interacted_with()
	elif Input.is_action_just_pressed("change_camera") \
	and not is_severed \
	and target.is_in_group("possessable") \
	and can_switch_cameras:
		change_camera_to(target)
#endregion

@rpc("any_peer", "call_local")
func start_ragdoll():
	frame.skeleton.physical_bones_start_simulation()
	physics_collision.set_disabled(true)

@rpc("any_peer", "call_local")
func stop_ragdoll():
	# Get the final position of the core bone
	var bone_position: Vector3 = frame.core_bone.get_global_position()

	# Weird hack to reset bones
	# When you start a simulation it seems that all bones reset
	frame.skeleton.physical_bones_stop_simulation()
	frame.skeleton.physical_bones_start_simulation()
	frame.skeleton.physical_bones_stop_simulation()

# Correct position and return to normal
	set_global_position(bone_position)
	physics_collision.set_disabled(false)

@rpc("any_peer", "call_local")
func unstuck():
	set_global_position(Vector3.ZERO)
	unstuck_progress = 0.0

func change_camera_to(target: Object):
	frame.camera.current = false
	target.camera.current = true

	is_severed = true
	sever_target = target

	can_switch_cameras = false
	sever_cooldown_timer.start()

func reset_camera():
	sever_target.camera.current = false
	frame.camera.current = true

	is_severed = false
	sever_target = null

	can_switch_cameras = false
	sever_cooldown_timer.start()





