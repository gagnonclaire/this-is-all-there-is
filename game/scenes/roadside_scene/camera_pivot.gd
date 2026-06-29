extends Node3D

var amplitude: float = 0.0005
var frequency: float = 0.0007

func _process(_delta):
	var bobbing_offset = sin(frequency * Time.get_ticks_msec()) * amplitude
	translate(Vector3(0, bobbing_offset, 0))
