extends Label

const SAFE_TEXT: String = "You feel safe here \nHold [$] to rest"

func _ready():
	var rest_input_event: InputEvent \
	= Keybinds.get_first_input_event(Keybinds.REST)

	set_text(SAFE_TEXT.replace("$", rest_input_event.as_text()))
