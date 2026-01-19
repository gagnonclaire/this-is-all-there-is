extends Control

const BINDING_BUTTON: PackedScene = preload("res://game/ui/menus/settings_menu/keybind_menu/binding_button.tscn")

@onready var v_box: VBoxContainer = $VBoxContainer

func _ready() -> void:
	var actions: Array[StringName] = Keybinds.get_input_actions()

	for action in actions:
		var action_button: Button = BINDING_BUTTON.instantiate()
		action_button.input_action = action
		v_box.add_child(action_button)
