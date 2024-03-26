extends Node

@export var character_name: String = ""

#TODO Array[String] cannot sync, maybe used a PackedStringArray for lines?
@export var character_lines: Array
@export var current_line: int = 0

@onready var frame: CharacterBody3D = $HumanFrame

#TODO Use navmesh stuff here
@onready var current_destination: Vector3 = frame.global_position

#region NPC setup
func _ready() -> void:
	if is_multiplayer_authority():
		character_name = ProceduralGeneration.get_human_name()
		frame.examine_text = character_name
		character_lines = ProceduralGeneration.get_human_lines(randi_range(2,3))
#endregion

#TODO Use a navmesh for wander
#TODO This should hook into frame controls rather than hijacking them
func _physics_process(delta) -> void:
	if is_multiplayer_authority():
		var direction = frame.global_position.direction_to(current_destination)
		if frame.global_position.distance_to(current_destination) < 0.1:
			frame.velocity = Vector3.ZERO
		else:
			# Smooth camera turning and linear motion
			var turn_transform = frame.transform.looking_at(current_destination, Vector3.UP)
			frame.transform  = frame.transform.interpolate_with(turn_transform, delta * 5)
			frame.velocity = direction

		frame.move_and_slide()

func _on_destination_update_timer_timeout() -> void:
	if is_multiplayer_authority():
		current_destination += Vector3(randf_range(-2.5, 2.5), 0, randf_range(-2.5, 2.5))

func interacted_with(_caller_id) -> void:
	frame.set_speech_label(character_lines[current_line])

	if is_multiplayer_authority():
		current_line = (current_line + 1) % character_lines.size()

func _on_name_update_timer_timeout() -> void:
	frame.examine_text = character_name
