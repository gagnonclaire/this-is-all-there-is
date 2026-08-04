extends Node3D

var amplitude: float = 0.01
var frequency: float = 0.0001

func _process(delta):
	var bobbing_offset = sin(frequency * Time.get_ticks_msec()) * amplitude * delta
	var rotation_offset = sin(frequency * Time.get_ticks_msec()) * amplitude * delta
	translate(Vector3(0, bobbing_offset, 0))
	rotate_y(rotation_offset)
