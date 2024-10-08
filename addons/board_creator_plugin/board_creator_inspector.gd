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

	var btn_growArea = Button.new()
	btn_growArea.set_text("Grow Area")
	btn_growArea.pressed.connect(object.GrowArea)
	add_custom_control(btn_growArea)

	var btn_shrinkArea = Button.new()
	btn_shrinkArea.set_text("Shrink Area")
	btn_shrinkArea.pressed.connect(object.ShrinkArea)
	add_custom_control(btn_shrinkArea)

	var btn_save = Button.new()
	btn_save.set_text("Save")
	btn_save.pressed.connect(object.Save)
	add_custom_control(btn_save)

	var btn_load_tile = Button.new()
	btn_load_tile.set_text("Load Tile")
	btn_load_tile.pressed.connect(object.load_tile)
	add_custom_control(btn_load_tile)

	var btn_saveJSON = Button.new()
	btn_saveJSON.set_text("Save JSON")
	btn_saveJSON.pressed.connect(object.SaveJSON)
	add_custom_control(btn_saveJSON)

	var btn_loadJSON = Button.new()
	btn_loadJSON.set_text("Load JSON")
	btn_loadJSON.pressed.connect(object.LoadJSON)
	add_custom_control(btn_loadJSON)
