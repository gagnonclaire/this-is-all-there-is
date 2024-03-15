# Functional human frame meant to be instantiated as a child
# of a character node
# The frame used by the player character
#
# Exposes its own functional nodes and the nodes of its
# children for access by its parent
#
# Has some of its own functionality that is global to
# all characters using this frame

extends Node3D

# Preload camera
const CAMERA_SCENE: PackedScene = preload("res://characters/2_parts_cameras/basic_camera.tscn")

# Exposed full body nodes
@onready var full_body: Node3D = $FullHumanBody
@onready var skeleton: Skeleton3D = full_body.skeleton
@onready var core_bone: PhysicalBone3D = full_body.core_bone
@onready var head_pivot: Node3D = full_body.head_pivot
@onready var camera_pivot: Node3D = full_body.camera_pivot

# Exposed camera nodes
var camera: Camera3D
var sever_camera: Camera3D
var interact_raycast: RayCast3D
var sever_raycast: RayCast3D

# Exposed frame nodes
@onready var speech_label: Label3D = $SpeechLabel
@onready var speech_clear_timer: Timer = $SpeechClearTimer
@onready var speech_audio_loop_timer: Timer = $SpeechAudioLoopTimer
@onready var speech_audio_loop_end_timer: Timer = $SpeechAudioLoopEndTimer
@onready var speech_audio_stream: AudioStreamPlayer3D = $SpeechAudioStream

#TODO everything below here is garbage
var stamina_drain_multiplier: float = 1.0

func _ready() -> void:
	# Create camera under the head pivot and expose its nodes
	var camera_node: Node3D = CAMERA_SCENE.instantiate()
	camera_pivot.add_child(camera_node)
	camera = camera_node.camera
	sever_camera = camera_node.sever_camera
	interact_raycast = camera_node.interact_raycast
	sever_raycast = camera_node.sever_raycast

func _on_speech_clear_timer_timeout():
	speech_label.set_text("")

func _on_speech_audio_loop_timer_timeout():
	speech_audio_stream.play()

func _on_speech_audio_loop_end_timer_timeout():
	speech_audio_loop_timer.stop()

#region Frame Ragdoll Functions
@rpc("any_peer", "call_local")
func start_ragdoll():
	skeleton.physical_bones_start_simulation()

@rpc("any_peer", "call_local")
func stop_ragdoll():
	# Weird hack to reset bones
	# When you start a simulation it seems that all bones reset
	skeleton.physical_bones_stop_simulation()
	skeleton.physical_bones_start_simulation()
	skeleton.physical_bones_stop_simulation()
#endregion

@rpc("any_peer", "call_local")
func set_speech_label(text: String, time: float = 3.0):
	speech_label.set_text(text)
	speech_clear_timer.set_wait_time(time)
	speech_clear_timer.start()
	start_speach_audio(text.length() / 20.0)

@rpc("any_peer", "call_local")
func start_speach_audio(time: float):
	speech_audio_loop_timer.start()
	speech_audio_loop_end_timer.set_wait_time(time)
	speech_audio_loop_end_timer.start()
