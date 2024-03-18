extends CharacterBody3D

const SPEED = 1.0

@export var character_name: String = ""
@export var character_lines: Array # Array[String] cannot sync, maybe used a PackedStringArray for lines?
@export var current_line: int = 0

@onready var frame: Node3D = $HumanFrame
@onready var world_node: Node = get_parent()
@onready var current_destination: Vector3 = get_global_position()

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var examine_text: String = "A Dummy"

func _ready():
	frame.stamina_drain_multiplier = 1.0

	if world_node.is_host:
		character_name = ProceduralGeneration.get_human_name()
		examine_text = character_name
		character_lines = ProceduralGeneration.get_human_lines(randi_range(2,3))

#TODO Use a navmesh for wander
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
	frame.set_speech_label(character_lines[current_line])

	if world_node.is_host:
		current_line = (current_line + 1) % character_lines.size()


func _on_name_update_timer_timeout():
	examine_text = character_name
