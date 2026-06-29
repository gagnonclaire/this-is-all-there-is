class_name BoardController
extends Node

signal add_character()

@onready var hud: CanvasLayer = $BoardControllerHUD
@onready var camera: BaseControllerCamera = $BaseControllerCamera

func show_hud():
	hud.show()

func hide_hud():
	hud.hide()

func transition_to_camera(from_position: Vector3, from_rotation: Vector3):
	camera.transition_to(from_position, from_rotation)

func deactivate_camera():
	camera.deactivate()

func _on_board_controller_hud_add_character():
	emit_signal("add_character")
