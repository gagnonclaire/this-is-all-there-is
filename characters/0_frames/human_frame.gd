extends Node3D

@onready var skeleton: Skeleton3D = $Armature/Skeleton3D
@onready var core_bone: PhysicalBone3D = $Armature/Skeleton3D/CoreBone
@onready var head_pivot: Node3D = $Armature/Skeleton3D/CoreBone/HeadPivot
@onready var camera: Camera3D = $Armature/Skeleton3D/CoreBone/HeadPivot/FrameCamera
@onready var short_raycast: RayCast3D = $Armature/Skeleton3D/CoreBone/HeadPivot/FrameCamera/ShortRayCast
@onready var speech_label: Label3D = $SpeechLabel
@onready var speech_clear_timer: Timer = $SpeechClearTimer
@onready var speech_audio_stream: AudioStreamPlayer3D = $SpeechAudioStream

func _on_speech_clear_timer_timeout():
	speech_label.set_text("")

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



