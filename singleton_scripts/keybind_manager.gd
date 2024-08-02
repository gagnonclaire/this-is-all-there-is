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
