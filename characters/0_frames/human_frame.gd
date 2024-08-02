# Base functional component to a human character
# Handles basic movement, built to be called by a controller

extends CharacterBody3D

# Preload camera
const CAMERA_SCENE: PackedScene = preload( \
	"res://characters/2_parts/cameras/basic_camera.tscn")

# Sync vars
@export var examine_text: String = "A Human"

# Exposed full body nodes
@onready var body: Node3D = $HumanBody
@onready var skeleton: Skeleton3D = body.skeleton
@onready var core_bone: PhysicalBone3D = body.core_bone
@onready var head_pivot: Node3D = body.head_pivot
@onready var camera_pivot: Node3D = body.camera_pivot

# Exposed frame nodes
@onready var speech_label: Label3D = $SpeechLabel
@onready var speech_clear_timer: Timer = $SpeechClearTimer
@onready var speech_audio_loop_timer: Timer = $SpeechAudioLoopTimer
@onready var speech_audio_loop_end_timer: Timer = $SpeechAudioLoopEndTimer
@onready var speech_audio_stream: AudioStreamPlayer3D = $SpeechAudioStream
@onready var world_collider: CollisionShape3D = $WorldCollider

# Exposed camera nodes
var camera: Camera3D
var interact_raycast: RayCast3D
var sever_raycast: RayCast3D
var hold_point: Node3D

# Character attribute vars
var speed: float = 5.0
var sprint_speed_modifier: float = 3.0
var maximum_stamina: float = 100.0
var current_stamina: float = maximum_stamina
var is_knocked_out: bool = false
var stamina_gain_base: float = 5.0
var stamina_gain_recovery: float = 20.0
var stamina_drain_sprint: float = 15.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Relationship tracker vars
var held_object: RigidBody3D = null

#region Instantiation
##############################################################################
func _ready() -> void:
	_instantiate_camera()

func _instantiate_camera() -> void:
	var camera_node: Node3D = CAMERA_SCENE.instantiate()
	camera_pivot.add_child(camera_node)
	camera = camera_node.camera
	interact_raycast = camera_node.interact_raycast
	sever_raycast = camera_node.sever_raycast
	hold_point = camera_node.hold_point
#endregion

#region Movement controls
##############################################################################
func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		if not is_on_floor():
			velocity.y -= gravity * delta

		_stamina_change(delta)
		_knockout_check()

		velocity = velocity.lerp(Vector3(0, velocity.y, 0), 0.25)

#		TODO Bring back this dropping mechanic somewhere else, maybe player controller?
		# Drop any held object if it is far away from the frame
		#if held_object:
			#var object_pos: Vector3 = held_object.get_global_position()
			#var hold_point_pos: Vector3 = hold_point.get_global_position()

			#if object_pos.distance_squared_to(hold_point_pos) > 5.0:
				#held_object.drop.rpc_id(1)

		move_and_slide()

@rpc("authority", "call_local")
func set_frame_movement(new_velocity: Vector3) -> void:
	if is_multiplayer_authority():
		velocity = new_velocity
#endregion

#region Stamina controls
##############################################################################
func get_current_stamina_percent() -> float:
	return current_stamina / maximum_stamina

func _stamina_change(delta: float) -> void:
	var stamina_change = delta * stamina_gain_base
	stamina_change += int(is_knocked_out) * (delta \
		* stamina_gain_recovery)
	stamina_change -= int(Input.is_action_pressed("sprint") \
		and not is_knocked_out) * (delta * stamina_drain_sprint)

	current_stamina = clampf(current_stamina + stamina_change, \
		0, maximum_stamina)

func _knockout_check() -> void:
	if current_stamina == 0 and not is_knocked_out:
		start_ragdoll.rpc()
		world_collider.set_disabled(true)
		is_knocked_out = true
	elif is_knocked_out and current_stamina == maximum_stamina:
		var bone_position: Vector3 = core_bone.get_global_position()
		stop_ragdoll.rpc()
		set_global_position(bone_position)
		world_collider.set_disabled(false)
		is_knocked_out = false
#endregion

#region Speech controls
##############################################################################
func _on_speech_clear_timer_timeout() -> void:
	speech_label.set_text("")

func _on_speech_audio_loop_timer_timeout() -> void:
	speech_audio_stream.play()

func _on_speech_audio_loop_end_timer_timeout() -> void:
	speech_audio_loop_timer.stop()

@rpc("any_peer", "call_local")
func set_speech_label(text: String, time: float = 3.0) -> void:
	speech_label.set_text(text)
	speech_clear_timer.set_wait_time(time)
	speech_clear_timer.start()
	start_speach_audio(text.length() / 20.0)

@rpc("any_peer", "call_local")
func start_speach_audio(time: float) -> void:
	speech_audio_loop_timer.start()
	speech_audio_loop_end_timer.set_wait_time(time)
	speech_audio_loop_end_timer.start()
#endregion

#region Ragdoll controls
##############################################################################
@rpc("any_peer", "call_local")
func start_ragdoll() -> void:
	skeleton.physical_bones_start_simulation()

@rpc("any_peer", "call_local")
func stop_ragdoll() -> void:
	# Weird hack to reset bones
	# When you start a simulation it seems that all bones reset
	skeleton.physical_bones_stop_simulation()
	skeleton.physical_bones_start_simulation()
	skeleton.physical_bones_stop_simulation()
#endregion

#TODO This is pretty fragile, assumes parent has this function
@rpc("any_peer", "call_local")
func interacted_with():
	get_parent().interacted_with(str(multiplayer.get_remote_sender_id()))
