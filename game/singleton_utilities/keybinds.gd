extends Node

const FORWARD: StringName = "forward"
const BACKWARD: StringName = "backward"
const LEFT: StringName = "left"
const RIGHT: StringName = "right"
const SPRINT: StringName = "sprint"
const INTERACT: StringName = "interact"
const REST: StringName = "rest"
const SEVER: StringName = "sever"
const AWAKEN: StringName = "awaken"
const GRAB: StringName = "grab"
const ROTATE: StringName = "rotate"
const TALK: StringName = "talk"
const TALK_ENTRY: StringName = "talk_entry"
const BABBLE: StringName = "babble"
const CONTROL_SELF: StringName = "control_self"
const MENU: StringName = "menu"
const TOGGLE_MOUSE_CAPTURE: StringName = "toggle_mouse_capture"

#TODO: Add support for multiple binds
const _DEFAULT_MAPPINGS: Dictionary = {
	FORWARD: Key.KEY_W,
	LEFT: Key.KEY_A,
	RIGHT: Key.KEY_D,
	BACKWARD: Key.KEY_S,
	SPRINT: Key.KEY_SHIFT,
	INTERACT: Key.KEY_E,
	REST: Key.KEY_R,
	SEVER: Key.KEY_F1,
	AWAKEN: Key.KEY_X,
	GRAB: MouseButton.MOUSE_BUTTON_LEFT,
	ROTATE: MouseButton.MOUSE_BUTTON_RIGHT,
	TALK: Key.KEY_T,
	TALK_ENTRY: Key.KEY_ENTER, #TODO: Add Kp Enter
	BABBLE: Key.KEY_B,
	CONTROL_SELF: Key.KEY_SPACE,
	MENU: Key.KEY_ESCAPE,
	TOGGLE_MOUSE_CAPTURE: Key.KEY_ALT,
}

var _override_mappings: Dictionary = {}

func _ready() -> void:
	# Lowest key enum is 'Space' at 32
	# can use that to check for mouse (0-9) vs. key
	for mapping in _DEFAULT_MAPPINGS:
		var event: InputEvent
		InputMap.add_action(mapping)

		if _override_mappings.has(mapping):
			if _override_mappings[mapping] >= 32:
				event = InputEventKey.new()
				event.set_keycode(_override_mappings[mapping])
			else:
				event = InputEventMouseButton.new()
				event.set_button_index(_override_mappings[mapping])
		else:
			if _DEFAULT_MAPPINGS[mapping] >= 32:
				event = InputEventKey.new()
				event.set_keycode(_DEFAULT_MAPPINGS[mapping])
			else:
				event = InputEventMouseButton.new()
				event.set_button_index(_DEFAULT_MAPPINGS[mapping])

		InputMap.action_add_event(mapping, event)

func get_input_actions() -> Array[StringName]:
	var full_actions: Array[StringName] = InputMap.get_actions()
	var game_actions: Array[StringName] = []

	for action in full_actions:
		if not (action.begins_with("ui") or action.begins_with("debug")):
			game_actions.append(action)

	return game_actions

func get_first_input_event(input_action: StringName) -> InputEvent:
	var input_events: Array[InputEvent] = InputMap.action_get_events(input_action)

	if input_events.size() == 0:
		return null
	else:
		return input_events[0]
