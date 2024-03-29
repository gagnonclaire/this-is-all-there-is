extends Label

const SAFE_TEXT: String = "You feel safe here \nPress [$] to rest"

func _ready():
	var rest_input_event: InputEvent \
	= KeybindManager.get_first_input_event(KeybindManager.REST)

	set_text(SAFE_TEXT.replace("$", rest_input_event.as_text()))
