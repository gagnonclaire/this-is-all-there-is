extends Label

const INTERACT_TEXT: String = "[$] Interact"

func _ready():
	var interact_input_event: InputEvent \
	= KeybindManager.get_first_input_event(KeybindManager.INTERACT)

	set_text(INTERACT_TEXT.replace("$", interact_input_event.as_text()))
