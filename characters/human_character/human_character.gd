extends CharacterBody3D

const SPEED = 5.0
const NPC_LINES_PATH: String = "res://characters/human_character/human_dialogue.txt"

@export var lines: Array
@export var current_line: int = 0
@export var camera: Camera3D

@onready var frame: Node3D = $HumanFrame
@onready var speech_bubble: Label3D = $SpeechBubble
@onready var speech_timer: Timer = $SpeechTimer

@onready var world_node: Node = get_parent()
@onready var main_node: Node = world_node.get_parent()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	camera = frame.camera

	# Read from lines file
	var lines_file: FileAccess = FileAccess.open(NPC_LINES_PATH, FileAccess.READ)
	var full_lines: Array = lines_file.get_as_text().split("\n")
	lines_file.close()

	# Choose two at random
	lines = [full_lines[randi() % full_lines.size()], full_lines[randi() % full_lines.size()]]

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()

func _on_speech_timer_timeout():
	# Clear text on timeout
	speech_bubble.text = ""

func interacted_with():
	rpc("speech")

@rpc("any_peer", "call_local")
func speech():
	current_line = (current_line + 1) % 2
	speech_bubble.text = lines[current_line]

	# Start the timer to clear text
	speech_timer.start()
