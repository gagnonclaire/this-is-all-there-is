extends Node3D

var amplitude: float = 0.00005
var frequency: float = 0.0005

func _process(_delta):
	# Bob camera using sine
	var bobbing_offset = sin(frequency * Time.get_ticks_msec()) * amplitude
	translate(Vector3(0, bobbing_offset, 0))
