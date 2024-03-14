extends Button

@export var input_action: String = ""

@onready var binding_button: Button = $"."
@onready var binding_label: Label = $BindingLabel
@onready var capture_cooldown_timer: Timer = $CaptureCooldown

var is_capturing: bool = false

func _ready() -> void:
	var input_event: InputEvent = get_first_input_event()

	binding_button.set_text(input_action)

	if input_event:
		binding_label.set_text(input_event.as_text())

func _input(event: InputEvent) -> void:
	if is_capturing \
	and (event is InputEventKey \
	or event is InputEventMouseButton):
		if event.as_text() == "Escape":
			cancel_binding()
		else:
			assign_input_event(event)

func _on_pressed() -> void:
	if not is_capturing:
		is_capturing = true
		clear_button_label()

func _on_capture_cooldown_timeout() -> void:
	is_capturing = false

func assign_input_event(event: InputEvent) -> void:
	var existing_input_event: InputEvent = get_first_input_event()
	if existing_input_event:
		InputMap.action_erase_event(input_action, existing_input_event)

	InputMap.action_add_event(input_action, event)
	binding_label.set_text(event.as_text())
	end_capture()

func cancel_binding() -> void:
	var existing_input_event: InputEvent = get_first_input_event()
	binding_label.set_text(existing_input_event.as_text())
	end_capture()

func clear_button_label() -> void:
	binding_label.set_text("_")

func get_first_input_event() -> InputEvent:
		var input_events: Array[InputEvent]

		input_events = InputMap.action_get_events(input_action)
		if input_events.size() == 0:
			return null

		return input_events[0]

func end_capture() -> void:
	binding_button.release_focus()
	capture_cooldown_timer.start()
