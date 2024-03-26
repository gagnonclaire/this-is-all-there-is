extends CanvasLayer

@onready var _important_notice: Label = $Control/ImportantNotice
@onready var _stamina_vignette: TextureRect = $Control/StaminaVignette
@onready var _awaken_vignette: TextureRect = $Control/AwakenVignette
@onready var _text_chat_entry: LineEdit = $Control/TextChatEntry
@onready var _examine_context_indicator: Label = $Control/ExamineContext
@onready var _interact_context_indicator: Label = $Control/ContextIndicators/InteractContext
@onready var _sever_context_indicator: Label = $Control/ContextIndicators/SeverContext

func _input(_event: InputEvent) -> void:
	if is_multiplayer_authority() \
	and is_text_chat_open():
		if Input.is_action_just_pressed("talk_entry"):
			_text_chat_entry.release_focus()

#region Text chat controllers
func open_text_chat() -> void:
	_text_chat_entry.show()
	_text_chat_entry.grab_focus()

func close_text_chat() -> void:
	_text_chat_entry.hide()
	_text_chat_entry.clear()
	_text_chat_entry.release_focus()

func is_text_chat_open() -> bool:
	return _text_chat_entry.visible

func get_text_entered() -> String:
	return _text_chat_entry.text

func _on_clear_timer_timeout() -> void:
	if is_multiplayer_authority():
		_important_notice.set_text("")
#endregion

#region Hud text information
func notify_important(message: String) -> void:
	if is_multiplayer_authority():
		_important_notice.set_text(message)
#endregion

#region Context indicators
func show_examine_context_indicator(examine_text: String) -> void:
	if is_multiplayer_authority():
		_examine_context_indicator.set_text(examine_text)

func show_interact_context_indicator(show_indicator: bool = true) -> void:
	if is_multiplayer_authority():
		_interact_context_indicator.set_visible(show_indicator)

func show_sever_context_indicator(show_indicator: bool = true) -> void:
	if is_multiplayer_authority():
		_sever_context_indicator.set_visible(show_indicator)
#endregion

#region Vignette modulation controls
func modulate_stamina_vignette(transparency: float) -> void:
	_stamina_vignette.set_modulate(Color(1.0, 1.0, 1.0, (transparency)))

func modulate_awaken_vignette(transparency: float) -> void:
	_awaken_vignette.set_modulate(Color(1.0, 1.0, 1.0, (transparency)))
#endregion
