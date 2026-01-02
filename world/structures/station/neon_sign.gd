class_name NeonSign
extends Node3D

@onready var neon_sign_mesh: MeshInstance3D = $Sign
@onready var neon_sign_editor: CanvasLayer = $Editor
@onready var neon_sign_interactable: StaticBody3D = $Sign/StaticBody3D

@onready var glow_control: HSlider = $Editor/Control/Sliders/GlowControl/HSlider
@onready var flicker_control: HSlider = $Editor/Control/Sliders/FlickerControl/HSlider
@onready var minimum_brightness_control: HSlider = $Editor/Control/Sliders/MinimumBrightnessControl/HSlider
@onready var energy_control: HSlider = $Editor/Control/Sliders/EnergyControl/HSlider
@onready var color_picker: ColorPicker = $Editor/Control/Sliders/ColorPicker

@export	var sign_texture: BaseMaterial3D
@export	var glow_color: Color = Color(1, 1, 1)

@export	var glow: float = 1.0
@export var flicker: float = 1.0
@export var minimum_brightness: float = 1.0
@export	var energy: float = 1.0

func _ready() -> void:
	color_picker.color = glow_color
	sign_texture.emission = glow_color
	neon_sign_mesh.set_surface_override_material(0, sign_texture)

	neon_sign_interactable.add_to_group("interact_target")
	neon_sign_interactable.set_collision_layer_value(CollisionLayerManager.PHYSICS_COLLISION_LAYER, true)
	neon_sign_interactable.set_collision_layer_value(CollisionLayerManager.INTERACTABLE_LAYER, true)

	neon_sign_editor.hide()

func _process(_delta) -> void:
	var glow_factor = Time.get_ticks_msec() / (glow * 100.0)
	var energy_flicker = flicker * (randf() - 0.5)
	var energy_offset = minimum_brightness + energy_flicker
	var current_energy = energy * (sin(glow_factor) + energy_offset)

	sign_texture.emission_energy_multiplier = current_energy

func _on_glow_value_changed(value) -> void:
	glow = value

func _on_flicker_value_changed(value) -> void:
	flicker = value

func _on_minimum_brightness_value_changed(value) -> void:
	minimum_brightness = value

func _on_energy_value_changed(value) -> void:
	energy = value

func _on_color_picker_color_changed(color):
	sign_texture.emission = color

func _on_sign_input_event(camera, event, event_position, normal, shape_idx) -> void:
	print(event)
	neon_sign_editor.show()
