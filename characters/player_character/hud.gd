extends CanvasLayer

@export var stamina_vignette: TextureRect
@export var unstuck_vignette: TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	stamina_vignette = $Control/StaminaVignette
	unstuck_vignette = $Control/UnstuckVignette
