extends Label

const SEVER_TEXT: String = "[$] Sever"

func _ready():
	var sever_input_event: InputEvent \
	= Keybinds.get_first_input_event(Keybinds.SEVER)

	set_text(SEVER_TEXT.replace("$", sever_input_event.as_text()))
