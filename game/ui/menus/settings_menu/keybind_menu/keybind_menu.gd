class_name KeybindMenu
extends Control

const KEYBIND_ITEM: PackedScene = preload("res://game/ui/menus/settings_menu/keybind_menu/keybind_item.tscn")

@onready var keybind_list: VBoxContainer = $KeybindListSrollContainer/KeybindList

func _on_save_keybinds_button_pressed() -> void:
	Keybinds.save_keybinds()

func _on_discard_changes_button_pressed() -> void:
	clear_keybind_items()
	Keybinds.load_keybinds()
	populate_keybind_items()

func _on_reset_keybinds_button_pressed():
	clear_keybind_items()
	Keybinds.reset_all_keybinds()
	populate_keybind_items()

func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		clear_keybind_items()
		populate_keybind_items()

func populate_keybind_items() -> void:
	var actions: Array[StringName] = Keybinds.get_input_actions()

	for action in actions:
		var action_button: HBoxContainer = KEYBIND_ITEM.instantiate()
		action_button.input_action = action
		keybind_list.add_child(action_button)

func clear_keybind_items() -> void:
	for child in keybind_list.get_children():
		keybind_list.remove_child(child)
		child.queue_free()
