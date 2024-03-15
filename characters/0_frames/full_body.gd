extends Node3D

const BODY_ARRAY: Array[PackedScene] = \
[ preload("res://characters/1_parts_bodies/human_body_1.tscn"), \
preload("res://characters/1_parts_bodies/human_body_2.tscn")]

@export var body_top_material: Material
@export var body_bottom_material: Material

@onready var body_pivot: Node3D = $Skeleton3D/CoreBone/BodyPivot

func _ready() -> void:
	var body_load = BODY_ARRAY.pick_random()
	var body_node: Node3D = body_load.instantiate()
	body_pivot.add_child(body_node)

	var body_mesh: MeshInstance3D = body_pivot.get_child(0).get_child(0)
	body_mesh.set_surface_override_material(0, body_top_material)
	body_mesh.set_surface_override_material(1, body_bottom_material)
