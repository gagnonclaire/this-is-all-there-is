extends CanvasLayer

@onready var control_node: Control = $Control
@onready var important_notice: Label = $Control/ImportantNotice
@onready var important_notice_clear_timer: Timer = $Control/ImportantNotice/ClearTimer
@onready var stamina_vignette: TextureRect = $Control/StaminaVignette
@onready var unstuck_vignette: TextureRect = $Control/UnstuckVignette
@onready var text_chat_entry: LineEdit = $Control/TextChatEntry

@onready var player_parent: CharacterBody3D = get_parent()

func _unhandled_key_input(_event):
	if Input.is_action_just_released("confirm") and text_chat_entry.is_visible():
			player_parent.send_message(text_chat_entry.get_text())
			text_chat_entry.release_focus()
			text_chat_entry.clear()

func _on_timer_timeout():
	important_notice.set_text("")

func notify_important(message: String):
	important_notice.set_text(message)
	important_notice_clear_timer.start()
