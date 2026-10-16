class_name BaseBody
extends RigidBody3D

@export var acceleration: float = 200.0
@export var top_speed: float = 5.0
@export var jump_power: float = 1.0

@onready var camera: InteractingCamera = $InteractingCamera
@onready var on_ground_raycast: RayCast3D = $OnGroundRayCast

func _ready():
	camera.activate()

func on_ground() -> bool:
	return on_ground_raycast.is_colliding()
