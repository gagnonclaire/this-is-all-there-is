extends CharacterBody3D

const SPEED = 5.0
const NPC_LINES_PATH: String = "res://characters/human_character/human_dialogue.txt"

@onready var frame: Node3D = $HumanFrame
@onready var camera: Camera3D = frame.camera

@onready var main_node: Node = get_tree().get_root().get_child(0)

var lines: Array
var current_line: int = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

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
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()

func interacted_with():
	frame.set_speech_label.rpc(lines[current_line])
	rpc("update_current_line")

@rpc("any_peer", "call_local")
func update_current_line():
	if main_node.is_host:
		current_line = (current_line + 1) % 2
