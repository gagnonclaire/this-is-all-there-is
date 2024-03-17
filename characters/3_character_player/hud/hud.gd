extends CanvasLayer

@onready var control_node: Control = $Control
@onready var important_notice: Label = $Control/ImportantNotice
@onready var important_notice_clear_timer: Timer = $Control/ImportantNotice/ClearTimer
@onready var stamina_vignette: TextureRect = $Control/StaminaVignette
@onready var unstuck_vignette: TextureRect = $Control/UnstuckVignette
@onready var text_chat_entry: LineEdit = $Control/TextChatEntry
@onready var interact_context_indicator: Label = $Control/ContextIndicators/InteractContext
@onready var sever_context_indicator: Label = $Control/ContextIndicators/SeverContext

@onready var player_parent: CharacterBody3D = get_parent()

func _unhandled_key_input(_event) -> void:
	if is_multiplayer_authority() \
	and Input.is_action_just_released("talk_entry") and text_chat_entry.is_visible():
			player_parent.send_message(text_chat_entry.get_text())
			text_chat_entry.release_focus()
			text_chat_entry.clear()

func _on_clear_timer_timeout() -> void:
	if is_multiplayer_authority():
		important_notice.set_text("")

# Top screen large text, for important things that happen
func notify_important(message: String) -> void:
	if is_multiplayer_authority():
		important_notice.set_text(message)
		important_notice_clear_timer.start()

# Dynamic context labels, placed under reticule
func show_interact_context_indicator(show_indicator: bool = true) -> void:
	if is_multiplayer_authority():
		interact_context_indicator.set_visible(show_indicator)

func show_sever_context_indicator(show_indicator: bool = true) -> void:
	if is_multiplayer_authority():
		sever_context_indicator.set_visible(show_indicator)
