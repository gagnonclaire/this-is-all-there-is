class_name BoardControllerHUD
extends CanvasLayer

signal add_character()

func _ready():
	hide()

func _on_add_character_button_pressed():
	emit_signal("add_character")
