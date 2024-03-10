extends Node3D

# Camera bob properties
var amplitude: float = 0.05
var frequency: float = 0.0005

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Bob camera using sine
	var bobbing_offset = sin(frequency * Time.get_ticks_msec()) * amplitude
	#print(bobbing_offset)
	set_position(Vector3(0, bobbing_offset, 0))
