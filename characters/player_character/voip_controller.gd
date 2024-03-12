extends Node3D

# VOIP is currently on hold, plan is to try steam integration from
# https://godotsteam.com/tutorials/voice/#__tabbed_1_2
# Doing raw data transfer via RPCs was not performant

const MAX_AMPLITUDE: float = 0.0
const INPUT_THRESHOLD: float = 0.005

@onready var input: AudioStreamPlayer3D = $Input
@onready var player_node: CharacterBody3D = get_parent()

var index: int
var capture: AudioEffectCapture
var playback: AudioStreamGeneratorPlayback
var output: AudioStreamPlayer3D
var receive: PackedFloat32Array = PackedFloat32Array()
var owner_id: int

func _enter_tree():
	set_multiplayer_authority(owner_id)

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_multiplayer_authority():
		input.stream = AudioStreamMicrophone.new()
		print("Input stream set up: ", input.stream)
		input.play()

		index = AudioServer.get_bus_index("Record")
		capture = AudioServer.get_bus_effect(index, 0)

	playback = output.get_stream_playback()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	if is_multiplayer_authority():
		process_recorded_audio()

	process_received_audio()

func process_recorded_audio():
	var data: PackedVector2Array = capture.get_buffer(capture.get_frames_available())

	if data.size() > 0:
		var packed_data: PackedFloat32Array = PackedFloat32Array()
		packed_data.resize(data.size())
		var max_amplitude: float = 0.0

		for i in range(data.size()):
			var data_value = (data[i].x + data[i].y) / 2
			max_amplitude = max(data_value, MAX_AMPLITUDE)
			packed_data[i] = data_value

		if max_amplitude > INPUT_THRESHOLD:
			rpc("send_data", packed_data)
			if player_node.is_severed:
				send_data(packed_data)

func process_received_audio():
	if receive.size() <= 0:
		return

	for i in range(min(playback.get_frames_available(), receive.size())):
		playback.push_frame(Vector2(receive[0], receive[0]))
		receive.remove_at(0)

@rpc("any_peer", "call_remote", "unreliable_ordered")
func send_data(data : PackedFloat32Array):
	receive.append_array(data)
