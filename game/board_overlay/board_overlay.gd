class_name BoardOverlay
extends Node3D

@onready var grid_map: GridMap = $OverlayGridMap
@onready var selection_grid_map: GridMap = $SelectionGridMap

var current_height: int = -1
var board_render_size: int = 25

func _ready() -> void:
	render_board_grid(current_height)

func _input(event) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var camera = get_viewport().get_camera_3d()
		var mouse_pos = get_viewport().get_mouse_position()

		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 1000.0

		var space_state = grid_map.get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to, 16)
		var result = space_state.intersect_ray(query)

		update_selection(result)

func _unhandled_input(_event) -> void:
	if Input.is_action_just_pressed(Keybinds.MENU):
		SceneChange.switch_to_main_menu()

	if Input.is_action_just_pressed(Keybinds.BOARD_EDITOR_DECREASE_GRID_HEIGHT):
		current_height -= 1
		render_board_grid(current_height)

	if Input.is_action_just_pressed(Keybinds.BOARD_EDITOR_INCREASE_GRID_HEIGHT):
		current_height += 1
		render_board_grid(current_height)

func update_selection(result: Dictionary) -> void:
	if result:
		var collider = result["collider"]

		if collider is GridMap:
			var cell_pos = collider.local_to_map(result["position"])
			var tile_id = collider.get_cell_item(cell_pos)

			if tile_id == 0:
				selection_grid_map.clear()
				selection_grid_map.set_cell_item(cell_pos, 0)

func render_board_grid(height: int) -> void:
	grid_map.clear()
	selection_grid_map.clear()

	for l in range(-board_render_size, board_render_size):
		for w in range(-board_render_size, board_render_size):
			grid_map.set_cell_item(Vector3i(l, height, w), 0)
