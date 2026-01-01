class_name NeonSign1
extends Node3D

@onready var neon_sign_mesh: MeshInstance3D = $MeshInstance3D
@onready var neon_sign_material: BaseMaterial3D  = neon_sign_mesh.get_surface_override_material(0)


func _ready() -> void:
	neon_sign_material.emission = Color(1, 0, 0)


func _process(_delta) -> void:
	var current_time = Time.get_ticks_msec() / 100.0
	var energy_flicker = 2 * (randf() - 0.5)
	var energy_offset = 3.0 + energy_flicker
	var energy_multiplier = 2.0
	var current_energy = energy_multiplier * (sin(current_time) + energy_offset)

	neon_sign_material.emission_energy_multiplier = current_energy
