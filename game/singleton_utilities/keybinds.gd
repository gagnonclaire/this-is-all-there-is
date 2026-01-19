extends Node

const KEYBIND_CONFIG: String = "user://keybinds.cfg"

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
const _DEFAULT_KEYBINDS: Dictionary = {
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

var keybinds: Dictionary

func _ready() -> void:
	_load_or_create_keybinds()

func _load_or_create_keybinds() -> void:
	if FileAccess.file_exists(KEYBIND_CONFIG):
		load_keybinds()
	else:
		_create_default_keybinds()

func _create_default_keybinds() -> void:
	keybinds.clear()
	if FileAccess.file_exists(KEYBIND_CONFIG):
		var keybind_config: ConfigFile = ConfigFile.new()
		var load_error = keybind_config.load(KEYBIND_CONFIG)
		if load_error != OK:
			return

		keybind_config.clear()
		keybind_config.save(KEYBIND_CONFIG)

	for keybind in _DEFAULT_KEYBINDS:
		keybinds[keybind] = _DEFAULT_KEYBINDS[keybind]

	save_keybinds()
	_set_all_keybinds()

func _event_from_key(key: int) -> InputEvent:
	if key <= 9: # Mouse buttons
		var mouse_event: InputEventMouseButton = InputEventMouseButton.new()
		mouse_event.button_index = key as MouseButton
		return mouse_event
	if key >= 32: # Keys
		var key_event: InputEventKey = InputEventKey.new()
		key_event.physical_keycode = key as Key
		return key_event

	return null

func _set_all_keybinds() -> void:
	for keybind in keybinds:
		_set_keybind(keybind, keybinds[keybind])

func _set_keybind(input_action: StringName, event_key: int) -> void:
	if not InputMap.has_action(input_action):
		InputMap.add_action(input_action)

	var existing_input_event: InputEvent =  get_first_input_event(input_action)
	if existing_input_event:
		InputMap.action_erase_event(input_action, existing_input_event)

	var event: InputEvent = _event_from_key(event_key)
	InputMap.action_add_event(input_action, event)

func get_first_input_event(input_action: StringName) -> InputEvent:
	var input_events: Array[InputEvent] = InputMap.action_get_events(input_action)

	if input_events.size() == 0:
		return null
	else:
		return input_events[0]

func get_input_actions() -> Array[StringName]:
	var full_actions: Array[StringName] = InputMap.get_actions()
	var game_actions: Array[StringName] = []

	for action in full_actions:
		if not (action.begins_with("ui") or action.begins_with("debug")):
			game_actions.append(action)

	return game_actions

func save_keybinds() -> void:
	var keybind_config: ConfigFile = ConfigFile.new()
	for keybind in keybinds:
		keybind_config.set_value(keybind, "key", keybinds[keybind])

	keybind_config.save(KEYBIND_CONFIG)

func load_keybinds() -> void:
	keybinds.clear()
	var keybind_config: ConfigFile = ConfigFile.new()
	var load_error = keybind_config.load(KEYBIND_CONFIG)
	if load_error != OK:
		return

	for keybind_entry in keybind_config.get_sections():
		var keybind = keybind_config.get_value(keybind_entry, "key")
		keybinds[keybind_entry] = keybind

	_set_all_keybinds()

func update_action(input_action: StringName, event: InputEvent) -> void:
	var event_key: int
	if event is InputEventKey:
		event_key = event.physical_keycode
	if event is InputEventMouseButton:
		event_key = event.button_index

	if event_key:
		keybinds[input_action] = event_key
		_set_keybind(input_action, event_key)

func reset_all_keybinds() -> void:
	_create_default_keybinds()

func reset_keybind(action: StringName) -> void:
	var default_action_key: int = _DEFAULT_KEYBINDS[action]
	update_action(action, _event_from_key(default_action_key))
