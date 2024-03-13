extends CharacterBody3D

const SEVER_STAMINA_DRAIN_MULTIPLIER: float = 1.0
const SPEED = 1.0
const NPC_LINES_PATH: String = "res://characters/human_character/human_dialogue.txt"

@onready var frame: Node3D = $HumanFrame
@onready var camera: Camera3D = frame.camera

@onready var main_node: Node = get_tree().get_root().get_child(0)
@onready var current_destination: Vector3 = get_global_position()

var lines: Array
var current_line: int = 0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var character_name: String = "A Human"

func _ready():
	# Read from lines file
	if main_node.is_host:
		var lines_file: FileAccess = FileAccess.open(NPC_LINES_PATH, FileAccess.READ)
		var full_lines: Array = lines_file.get_as_text().split("\n")
		var line1: int = randi_range(0, full_lines.size() - 1)
		var line2: int = randi_range(0, full_lines.size() - 1)
		lines = [full_lines[line1], full_lines[line2]]
		lines_file.close()

func _physics_process(delta):
	if main_node.is_host:
		if not is_on_floor():
			velocity.y -= gravity * delta

		var direction = global_position.direction_to(current_destination)
		if global_position.distance_to(current_destination) < 0.1:
			velocity = Vector3.ZERO
		else:
			velocity = direction * SPEED

		move_and_slide()

func _on_destination_update_timer_timeout():
	if main_node.is_host:
		current_destination += Vector3(randf_range(-2.5, 2.5), 0, randf_range(-2.5, 2.5))
		look_at(current_destination)

@rpc("any_peer", "call_local")
func interacted_with():
	frame.set_speech_label(lines[current_line])

	if main_node.is_host:
		current_line = (current_line + 1) % 2
