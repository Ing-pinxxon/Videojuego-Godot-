extends Node2D

@onready var minimap = $CanvasLayer/TextureRect
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	minimap.visible = false

func _input(event):
	if event.is_action_pressed("minimap"):
		minimap.visible = !minimap.visible
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
