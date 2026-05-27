extends Area2D

# Número de este interruptor en la secuencia
@export var numero: int = 1

var jugador_cerca := false
var activado := false

@onready var sprite = $Sprite2D

func _process(_delta):
	if jugador_cerca and Input.is_action_just_pressed("ui_accept"):
		activar()

func activar() -> void:
	activado = true
	sprite.modulate = Color(1, 0.5, 0)  # naranja = presionado
	get_parent().interruptor_presionado(numero)

func resetear() -> void:
	activado = false
	sprite.modulate = Color(1, 1, 1)

func _on_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		jugador_cerca = true

func _on_body_exited(body):
	if body.name == "Player" or body.is_in_group("player"):
		jugador_cerca = false
