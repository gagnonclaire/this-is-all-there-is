class_name ScreenLight
extends AreaLight3D

@export	var glow_color1: Color = Color(0.75, 0.561, 0.435, 1.0)
@export	var glow_color2: Color = Color(0.28, 0.7, 0.679, 1.0)
@export	var glow_color3: Color = Color(0.79, 0.371, 0.664, 1.0)
@export	var glow_color4: Color = Color(0.82, 0.82, 0.82, 1.0)

@export var flicker: float = 0.1
@export	var energy: float = 1.0

@onready var target_color: Color = glow_color1
@onready var color_array: Array = [glow_color1, glow_color2, glow_color3, glow_color4]

func _process(delta):
	change_energy(delta)
	change_color(delta)

func change_energy(delta):
	var energy_flicker = randf_range(-flicker, flicker)
	var current_energy = energy + energy_flicker

	light_energy = current_energy

func change_color(delta):
	if randf() > 0.95:
		target_color  = color_array[randi_range(0, 3)]

	light_color = light_color.lerp(target_color, randf_range(1, 3) * delta)
