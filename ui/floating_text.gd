extends Node3D

@export var default_text: String

@onready var label: Label3D = $Label3D

var bobbing_amplitude: float = 1
var bobbing_frequency: float = 1

func _ready() -> void:
	label.text = default_text

func _process(_delta: float) -> void:
	# Need very small actual values for frequency and amplitude, do that here to keep vars nice
	var bobbing_offset = sin((bobbing_frequency / 1000) * Time.get_ticks_msec()) * bobbing_amplitude / 5000
	translate(Vector3(0, bobbing_offset, 0))

func set_text(text: String) -> void:
	label.text = text
