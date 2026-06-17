class_name AudioSource3D
extends Node3D

@onready var audio_stream_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var target_ray_cast: RayCast3D = $TargetRayCast3D

@export var follow_distance: float = 300
@export var stop_distance: float = 10
@export var speed: float = 1
