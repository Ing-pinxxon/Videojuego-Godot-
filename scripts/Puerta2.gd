extends Area2D

var jugador_dentro := false
var puerta_abierta := false

@onready var anim = $AnimatedSprite2D2
@onready var bloqueo = $"../StaticBody2D2/CollisionShape2D_Bloqueo2"


	
func _process(delta):
	if jugador_dentro:
		if Input.is_action_just_pressed("ui_accept"):
			toggle_puerta()
			
func toggle_puerta():
	if puerta_abierta:
		cerrar_puerta()
	else:
		abrir_puerta()
func abrir_puerta():
	puerta_abierta = true
	anim.play("Abrir")
	bloqueo.disabled = true  

func cerrar_puerta():
	puerta_abierta = false
	anim.play("Cerrar")
	bloqueo.disabled = false  

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		jugador_dentro = true


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		jugador_dentro = false
