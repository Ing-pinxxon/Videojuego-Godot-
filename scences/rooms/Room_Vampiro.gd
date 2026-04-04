extends Area2D

@export var next_scene_path: String
@onready var anim = $AnimatedSprite2D

var abierta = false
var jugador_cerca = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		jugador_cerca = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		jugador_cerca = false

func _process(delta: float) -> void:
	if jugador_cerca and not abierta:
		if Input.is_action_just_pressed("ui_accept"): # ESPACIO
			abrir_puerta()

func abrir_puerta() -> void:
	if anim != null:
		abierta = true
		anim.play("abrir")
		
		# Espera un poco (ajusta según tu animación)
		await get_tree().create_timer(0.8).timeout
		
		change_scene()
	else:
		print("Error: AnimatedSprite2D no encontrado")

func change_scene() -> void:
	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)
	else:
		print("Ruta de escena vacía")
