class_name KeybindItem
extends HBoxContainer

@export var input_action: StringName = ""

@onready var keybind_entry: Button = $KeybindEntry
@onready var keybind_label: Label = $KeybindLabel
@onready var capture_cooldown_timer: Timer = $KeybindCaptureCooldown

var is_capturing: bool = false

func _ready() -> void:
	keybind_label.set_text(input_action)
	var input_event: InputEvent = Keybinds.get_first_input_event(input_action)
	if input_event:
		keybind_entry.set_text(input_event.as_text())

func _input(event: InputEvent) -> void:
	if is_capturing \
	and (event is InputEventKey \
	or event is InputEventMouseButton):
		if event.as_text() == "Escape":
			cancel_binding()
		else:
			assign_input_event(event)

func _on_keybind_entry_pressed() -> void:
	if not is_capturing:
		is_capturing = true
		clear_button_label()

func _on_keybind_default_pressed():
	Keybinds.reset_keybind(input_action)
	var input_event: InputEvent = Keybinds.get_first_input_event(input_action)
	keybind_entry.set_text(input_event.as_text())

func _on_keybind_capture_cooldown_timeout() -> void:
	is_capturing = false

func assign_input_event(event: InputEvent) -> void:
	Keybinds.update_action(input_action, event)
	keybind_entry.set_text(event.as_text())
	end_capture()

func cancel_binding() -> void:
	var existing_input_event: InputEvent = Keybinds.get_first_input_event(input_action)
	keybind_entry.set_text(existing_input_event.as_text())
	end_capture()

func clear_button_label() -> void:
	keybind_entry.set_text("_")

func end_capture() -> void:
	release_focus()
	capture_cooldown_timer.start()
