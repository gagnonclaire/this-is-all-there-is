# Fully modular human body capable of simple ragdoll mechanics
# Consists of a head, body, hands, and feet
#
# Body part scenes should be added as children to their respective pivot
#
# This scene exposes common attachment points

extends Node3D

# Preload all part type meshes
const TORSO_ARRAY: Array[PackedScene] = \
[ preload("res://game/characters/2_parts/torsos/human_torso_1.tscn"), \
preload("res://game/characters/2_parts/torsos/human_torso_2.tscn")]
const HEAD_ARRAY: Array[PackedScene] = \
[ preload("res://game/characters/2_parts/heads/human_head_1.tscn")]
const HAND_ARRAY: Array[PackedScene] = \
[ preload("res://game/characters/2_parts/hands/human_hand_1.tscn")]
const FOOT_ARRAY: Array[PackedScene] = \
[ preload("res://game/characters/2_parts/feet/human_foot_1.tscn")]

# Synced variables
@export var torso_type: int = 0
@export var head_type: int = 0
@export var hand_type: int = 0
@export var foot_type: int = 0
@export var skin_color: Color = Color(1, 1, 1, 1)
@export var torso_top_color: Color = Color(1, 1, 1, 1)
@export var torso_bottom_color: Color = Color(1, 1, 1, 1)
@export var foot_color: Color = Color(1, 1, 1, 1)

# Exposed nodes
@onready var skeleton: Skeleton3D = $Skeleton3D
@onready var core_bone: PhysicalBone3D = $Skeleton3D/CoreBone
@onready var head_pivot: Node3D = $Skeleton3D/CoreBone/HeadPivot
@onready var head_mesh_pivot: Node3D = $Skeleton3D/CoreBone/HeadPivot/HeadMeshPivot
@onready var hair_mesh_pivot: Node3D = $Skeleton3D/CoreBone/HeadPivot/HairMeshPivot
@onready var camera_pivot: Node3D = $Skeleton3D/CoreBone/HeadPivot/CameraPivot
@onready var torso_pivot: Node3D = $Skeleton3D/CoreBone/TorsoPivot
@onready var left_hand_pivot: Node3D = $Skeleton3D/CoreBone/LeftHandPivot
@onready var right_hand_pivot: Node3D = $Skeleton3D/CoreBone/RightHandPivot
@onready var left_foot_pivot: Node3D = $Skeleton3D/CoreBone/LeftFootPivot
@onready var right_foot_pivot: Node3D = $Skeleton3D/CoreBone/RightFootPivot

# Part scenes
var torso_node: Node3D = null
var head_mesh_node: Node3D = null
var left_hand_node: Node3D = null
var right_hand_node: Node3D = null
var left_foot_node: Node3D = null
var right_foot_node: Node3D = null

func _ready() -> void:
	if is_multiplayer_authority():
		torso_type = randi_range(0, TORSO_ARRAY.size() - 1)
		head_type = randi_range(0, HEAD_ARRAY.size() - 1)
		hand_type = randi_range(0, HAND_ARRAY.size() - 1)
		foot_type = randi_range(0, FOOT_ARRAY.size() - 1)

		skin_color = Color(randf(), randf(), randf(), 1)
		torso_top_color = Color(randf(), randf(), randf(), 1)
		torso_bottom_color = Color(randf(), randf(), randf(), 1)
		foot_color = Color(randf(), randf(), randf(), 1)

#TODO Replace this timer hack with an actual way to load colors after sync
#TODO They are syncing just fine but never updating after that
func _on_body_update_timer_timeout():
	update_body()

#TODO Rewrite this so its not just a bunch of duplicate code
func update_body() -> void:
	if not torso_node:
		# Head
		head_mesh_node = HEAD_ARRAY[head_type].instantiate()
		head_mesh_pivot.add_child(head_mesh_node)
		var head_material = StandardMaterial3D.new()
		head_material.set_albedo(skin_color)
		var head_mesh: MeshInstance3D = head_mesh_pivot.get_child(0).get_child(0)
		head_mesh.set_surface_override_material(0, head_material)

		# Body
		torso_node = TORSO_ARRAY[torso_type].instantiate()
		torso_pivot.add_child(torso_node)
		var torso_top_material = StandardMaterial3D.new()
		var torso_bottom_material = StandardMaterial3D.new()
		torso_top_material.set_albedo(torso_top_color)
		torso_bottom_material.set_albedo(torso_bottom_color)
		var torso_mesh: MeshInstance3D = torso_pivot.get_child(0).get_child(0)
		torso_mesh.set_surface_override_material(0, torso_top_material)
		torso_mesh.set_surface_override_material(1, torso_bottom_material)

		# Hands
		left_hand_node = HAND_ARRAY[hand_type].instantiate()
		right_hand_node = HAND_ARRAY[hand_type].instantiate()
		left_hand_pivot.add_child(left_hand_node)
		right_hand_pivot.add_child(right_hand_node)
		var hand_material = StandardMaterial3D.new()
		hand_material.set_albedo(skin_color)
		var left_hand_mesh: MeshInstance3D = left_hand_pivot.get_child(0).get_child(0)
		var right_hand_mesh: MeshInstance3D = right_hand_pivot.get_child(0).get_child(0)
		left_hand_mesh.set_surface_override_material(0, hand_material)
		right_hand_mesh.set_surface_override_material(0, hand_material)

		# Feet
		left_foot_node = FOOT_ARRAY[foot_type].instantiate()
		right_foot_node = FOOT_ARRAY[foot_type].instantiate()
		left_foot_pivot.add_child(left_foot_node)
		right_foot_pivot.add_child(right_foot_node)
		var foot_material = StandardMaterial3D.new()
		foot_material.set_albedo(foot_color)
		var left_foot_mesh: MeshInstance3D = left_foot_pivot.get_child(0).get_child(0)
		var right_foot_mesh: MeshInstance3D = right_foot_pivot.get_child(0).get_child(0)
		left_foot_mesh.set_surface_override_material(0, foot_material)
		right_foot_mesh.set_surface_override_material(0, foot_material)
