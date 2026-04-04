extends Area2D

@onready var anim = $AnimatedSprite2D
var abierta = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not abierta:
		abrir_puerta()

func abrir_puerta() -> void:
	if anim != null:
		abierta = true
		anim.play("PUERTA") # 👈 nombre correcto
	else:
		print("Error: AnimatedSprite2D no encontrado")
