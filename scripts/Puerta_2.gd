extends Area2D
# Este script controla una puerta que, al interactuar con el jugador,
# reproduce una animación y cambia de escena a mitad de la animación.

# Indica si el jugador está dentro del área de interacción
var jugador_dentro := false

# Estado de la puerta (true = abierta, false = cerrada)
var puerta_abierta := false

# Evita que la transición se ejecute múltiples veces seguidas
var en_transicion := false 

# Referencia al AnimatedSprite2D que contiene las animaciones de la puerta
@onready var anim = $AnimatedSprite2D2

# Referencia al CollisionShape2D que bloquea el paso
@onready var bloqueo = $"../StaticBody2D/CollisionShape2D_Bloqueo2"

# Ruta de la siguiente escena (se asigna desde el editor)
@export var next_scene_path: String


func _process(delta):
	# Se ejecuta en cada frame
	
	# Verifica:
	# 1. Que el jugador esté dentro del área
	# 2. Que presione la tecla de interacción (ui_accept)
	# 3. Que no haya una transición en curso
	if jugador_dentro and Input.is_action_just_pressed("ui_accept") and not en_transicion:
		
		# Si la puerta aún no está abierta
		if not puerta_abierta:
			# Abre la puerta y luego cambia de escena a mitad de la animación
			abrir_puerta_y_cambiar()
		else:
			# Si ya está abierta, cambia directamente de escena
			change_scene()


# =========================
# ABRIR Y CAMBIAR A MITAD
# =========================

func abrir_puerta_y_cambiar():
	# Marca la puerta como abierta
	puerta_abierta = true
	
	# Activa el estado de transición para evitar múltiples ejecuciones
	en_transicion = true
	
	# Reproduce la animación de apertura
	anim.play("Abrir")
	
	# Si existe el bloqueo, desactiva la colisión para permitir el paso
	if bloqueo:
		bloqueo.disabled = true
	
	# 👇 Obtener información de la animación
	
	# Velocidad de la animación (frames por segundo)
	var duracion = anim.sprite_frames.get_animation_speed("Abrir")
	
	# Número total de frames de la animación
	var frames = anim.sprite_frames.get_frame_count("Abrir")
	
	# Tiempo total de la animación = cantidad de frames / velocidad (fps)
	var tiempo_total = frames / duracion
	
	# Espera una fracción del tiempo total (aproximadamente la mitad)
	await get_tree().create_timer(tiempo_total / 2.5).timeout
	
	# Luego de la espera, cambia de escena
	change_scene()


# =========================
# CAMBIO DE ESCENA
# =========================

func change_scene():
	# Verifica que se haya asignado una ruta de escena
	if next_scene_path != "":
		# Cambia a la escena especificada
		get_tree().change_scene_to_file(next_scene_path)
	else:
		# Muestra advertencia si no hay ruta asignada
		print("⚠️ No hay ruta de escena asignada")


# =========================
# DETECCIÓN DEL JUGADOR
# =========================

func _on_body_entered(body):
	# Se ejecuta cuando un cuerpo entra al área
	
	# Verifica que sea el jugador
	if body.name == "Player":
		# Activa la interacción
		jugador_dentro = true

func _on_body_exited(body):
	# Se ejecuta cuando un cuerpo sale del área
	
	# Verifica que sea el jugador
	if body.name == "Player":
		# Desactiva la interacción
		jugador_dentro = false
