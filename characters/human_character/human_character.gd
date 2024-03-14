extends CharacterBody3D

const SPEED = 1.0
const NPC_LINES_PATH: String = "res://characters/human_character/human_dialogue.txt"

@onready var frame: Node3D = $HumanFrame

@onready var world_node: Node = get_parent()
@onready var current_destination: Vector3 = get_global_position()

var lines: Array
var current_line: int = 0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var character_name: String = "A Human"

func _ready():
	frame.stamina_drain_multiplier = 1.0

	# Read from lines file
	if world_node.is_host:
		var lines_file: FileAccess = FileAccess.open(NPC_LINES_PATH, FileAccess.READ)
		var full_lines: Array = lines_file.get_as_text().split("\n")
		var line1: int = randi_range(0, full_lines.size() - 1)
		var line2: int = randi_range(0, full_lines.size() - 1)
		lines = [full_lines[line1], full_lines[line2]]
		lines_file.close()

func _physics_process(delta):
	if world_node.is_host:
		if not is_on_floor():
			velocity.y -= gravity * delta

		var direction = global_position.direction_to(current_destination)
		if global_position.distance_to(current_destination) < 0.1:
			velocity = Vector3.ZERO
		else:
			# Smooth camera turning and linear motion
			var turn_transform = transform.looking_at(current_destination, Vector3.UP)
			transform  = transform.interpolate_with(turn_transform, delta * 5)
			velocity = direction * SPEED

		move_and_slide()

func _on_destination_update_timer_timeout():
	if world_node.is_host:
		current_destination += Vector3(randf_range(-2.5, 2.5), 0, randf_range(-2.5, 2.5))

@rpc("any_peer", "call_local")
func interacted_with():
	frame.set_speech_label(lines[current_line])

	if world_node.is_host:
		current_line = (current_line + 1) % 2
