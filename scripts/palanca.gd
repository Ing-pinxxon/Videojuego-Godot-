extends Area2D

var activada := false
var jugador_cerca := false

@onready var sprite = $Sprite2D

func _process(_delta):
	if jugador_cerca and Input.is_action_just_pressed("ui_accept"):
		alternar()

func alternar() -> void:
	activada = !activada
	if activada:
		sprite.modulate = Color(0, 1, 0)
		get_parent().palanca_activada()
	else:
		sprite.modulate = Color(1, 1, 1)
		get_parent().palanca_desactivada()

func _on_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		jugador_cerca = true

func _on_body_exited(body):
	if body.name == "Player" or body.is_in_group("player"):
		jugador_cerca = false
