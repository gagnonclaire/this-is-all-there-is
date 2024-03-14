extends Control

const BINDING_BUTTON: PackedScene = preload("res://main_menu/settings/keybinding/binding_button.tscn")

@onready var v_box: VBoxContainer = $ScrollContainer/VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var actions: Array[StringName] = InputMap.get_actions()

	for action in actions:
		if not (action.begins_with("ui") or action.begins_with("debug")):
			var action_button: Button = BINDING_BUTTON.instantiate()
			action_button.input_action = action
			v_box.add_child(action_button)
