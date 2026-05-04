extends Area2D
# Este script se adjunta a un Area2D que detecta cuando el jugador está cerca de la puerta

# Variable que indica si el jugador está dentro del área de interacción
var jugador_dentro := false

# Variable que guarda el estado de la puerta (abierta o cerrada)
var puerta_abierta := false

# Referencia al nodo AnimatedSprite2D que controla la animación de la puerta
@onready var anim = $AnimatedSprite2D

# Referencia al CollisionShape2D que bloquea el paso (la "pared" de la puerta)
@onready var bloqueo = $"../StaticBody2D/CollisionShape2D_Bloqueo"

	
# Ruta de la siguiente escena (se asigna desde el editor si es una puerta de salida)
@export var next_scene_path: String

# Evita que la transición se ejecute múltiples veces seguidas
var en_transicion := false 

func _process(_delta):
	# Esta función se ejecuta en cada frame
	
	# Verifica si el jugador está dentro del área y presiona interactuar
	if jugador_dentro and Input.is_action_just_pressed("ui_accept") and not en_transicion:
		if not puerta_abierta:
			# Si la puerta está cerrada, intentar abrirla
			abrir_puerta()
		else:
			# Si ya está abierta
			if next_scene_path != "":
				# Si tiene ruta, cambiar de escena
				change_scene()
			else:
				# Si no tiene ruta (es una puerta normal), cerrarla
				cerrar_puerta()

func _hay_enemigos_vivos():
	# Busca enemigos en la misma sala (como hermanos del nodo puerta)
	var parent = get_parent()
	if parent:
		for child in parent.get_children():
			# Solo contar si es un Nodo2D, su nombre empieza por Enemy y es visible
			if child is Node2D and child.name.contains("Enemy") and child.visible:
				return true
	return false

func toggle_puerta():
	# Función que alterna el estado de la puerta
	if puerta_abierta:
		cerrar_puerta()
	else:
		abrir_puerta()

func abrir_puerta():
	# NO abrir si hay enemigos
	if _hay_enemigos_vivos():
		print("⚠️ Elimina todos los enemigos primero")
		return
	
	puerta_abierta = true
	anim.play("Abrir")
	
	if bloqueo:
		bloqueo.disabled = true
	
	# Si tiene una ruta de escena, podemos iniciar el cambio
	if next_scene_path != "":
		en_transicion = true
		# Esperar un poco a que la animación avance
		await get_tree().create_timer(0.5).timeout
		change_scene()

func cerrar_puerta():
	# Función para cerrar la puerta
	puerta_abierta = false
	anim.play("Cerrar")
	if bloqueo:
		bloqueo.disabled = false  

func change_scene():
	if next_scene_path != "":
		print("Cambiando a escena: ", next_scene_path)
		get_tree().change_scene_to_file(next_scene_path)

func _on_body_entered(body):
	# Esta función se ejecuta cuando un cuerpo entra al área
	if body.name == "Player" or body.is_in_group("player"):
		jugador_dentro = true

func _on_body_exited(body):
	# Esta función se ejecuta cuando un cuerpo sale del área
	if body.name == "Player" or body.is_in_group("player"):
		jugador_dentro = false
