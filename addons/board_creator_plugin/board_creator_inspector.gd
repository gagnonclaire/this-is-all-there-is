@tool
extends EditorInspectorPlugin

func _can_handle(object):
	if object is BoardCreator:
		return true
	return false

func _parse_begin(object):
	var btn_clear = Button.new()
	btn_clear.set_text("Clear")
	btn_clear.pressed.connect(object.clear)
	add_custom_control(btn_clear)

	var btn_create = Button.new()
	btn_create.set_text("Create")
	btn_create.pressed.connect(object.create)
	add_custom_control(btn_create)

	var btn_delete = Button.new()
	btn_delete.set_text("Delete")
	btn_delete.pressed.connect(object.delete)
	add_custom_control(btn_delete)

	var btn_save = Button.new()
	btn_save.set_text("Save")
	btn_save.pressed.connect(object.save_map)
	add_custom_control(btn_save)

	var btn_load = Button.new()
	btn_load.set_text("Load")
	btn_load.pressed.connect(object.load_map)
	add_custom_control(btn_load)
