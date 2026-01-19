class_name MainMenu
extends CanvasLayer

const MAIN_MENU_SCENE: PackedScene = preload("res://game/scenes/roadside_scene/roadside.tscn")

func _ready() -> void:
	add_child(MAIN_MENU_SCENE.instantiate())
	EventsManager.free_mouse()

func _unhandled_input(_event) -> void:
	if Input.is_action_just_pressed("menu"):
		get_tree().quit()
