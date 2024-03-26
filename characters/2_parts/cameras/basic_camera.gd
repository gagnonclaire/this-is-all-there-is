# Standard camera used by players and many other characters
# Can interact with things, be severed to, and sever from
# Usually put on the HeadPivot node of a frame

extends Node3D

# Exposed nodes
@onready var camera: Camera3D = $Camera
@onready var interact_raycast: RayCast3D = $Camera/InteractRayCast
@onready var sever_raycast: RayCast3D = $Camera/SeverRayCast
@onready var hold_point: Node3D = $Camera/HoldPoint
