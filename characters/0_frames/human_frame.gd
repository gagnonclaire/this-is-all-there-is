extends Node3D

@export var skeleton: Skeleton3D
@export var core_bone: PhysicalBone3D
@export var camera: Camera3D
@export var interact_raycast: RayCast3D

# Called when the node enters the scene tree for the first time.
func _ready():
	skeleton = $Armature/Skeleton3D
	core_bone = $Armature/Skeleton3D/CoreBone
	camera = $Armature/Skeleton3D/CoreBone/FrameCamera
	interact_raycast = $Armature/Skeleton3D/CoreBone/FrameCamera/InteractRayCast
