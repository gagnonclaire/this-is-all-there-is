class_name BoardOverlay
extends Node3D

const _CHARACTER_SCENE: PackedScene = preload("res://game/characters/pawn/pawn.tscn")

@onready var board_controller: BoardController = $BoardController
@onready var grid_map: GridMap = $OverlayGridMap
@onready var selection_grid_map: GridMap = $SelectionGridMap

var active: bool = false
var current_height: int = -1
var board_render_size: int = 25

var selection_position: Vector3i

func _ready():
	render_board_grid(current_height)

	grid_map.hide()
	selection_grid_map.hide()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var camera = get_viewport().get_camera_3d()
		var mouse_pos = get_viewport().get_mouse_position()

		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 1000.0

		var space_state = grid_map.get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to, 16)
		var result = space_state.intersect_ray(query)

		update_selection(result)

	if Input.is_action_just_pressed(Keybinds.MENU):
		SceneChange.switch_to_main_menu()

	if Input.is_action_just_pressed(Keybinds.BOARD_EDITOR_DECREASE_GRID_HEIGHT):
		current_height -= 1
		render_board_grid(current_height)

	if Input.is_action_just_pressed(Keybinds.BOARD_EDITOR_INCREASE_GRID_HEIGHT):
		current_height += 1
		render_board_grid(current_height)

func make_active():
	active = true
	board_controller.active = true
	board_controller.board_controller_hud.show()
	grid_map.show()
	selection_grid_map.show()
	board_controller.board_controller_camera.make_current()


func make_inactive():
	active = false
	board_controller.active = false
	board_controller.board_controller_hud.hide()
	grid_map.hide()
	selection_grid_map.hide()

func render_board_grid(height: int):
	grid_map.clear()
	selection_grid_map.clear()

	for l in range(-board_render_size, board_render_size):
		for w in range(-board_render_size, board_render_size):
			grid_map.set_cell_item(Vector3i(l, height, w), 0)

func update_selection(result: Dictionary):
	if result:
		var collider = result["collider"]

		if collider is GridMap:
			selection_position = collider.local_to_map(result["position"])
			var tile_id = collider.get_cell_item(selection_position)

			if tile_id == 0:
				selection_grid_map.clear()
				selection_grid_map.set_cell_item(selection_position, 0)

func _on_board_controller_add_character():
	if selection_position:
		var local_selection_position = grid_map.map_to_local(selection_position)
		var character: Node3D = _CHARACTER_SCENE.instantiate()
		character.position = local_selection_position
		add_child(character)
