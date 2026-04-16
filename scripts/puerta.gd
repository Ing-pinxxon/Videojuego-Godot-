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

	
func _process(delta):
	# Esta función se ejecuta en cada frame
	
	# Verifica si el jugador está dentro del área
	if jugador_dentro:
		# Detecta si se presiona la tecla de interacción (por defecto: espacio o enter)
		if Input.is_action_just_pressed("ui_accept"):
			# Llama a la función que abre o cierra la puerta
			toggle_puerta()


func toggle_puerta():
	# Función que alterna el estado de la puerta
	
	if puerta_abierta:
		# Si la puerta ya está abierta, la cierra
		cerrar_puerta()
	else:
		# Si la puerta está cerrada, la abre
		abrir_puerta()


func abrir_puerta():
	# Función para abrir la puerta
	
	# Cambia el estado a abierta
	puerta_abierta = true
	
	# Reproduce la animación de abrir
	anim.play("Abrir")
	
	# Desactiva la colisión para permitir el paso
	bloqueo.disabled = true  


func cerrar_puerta():
	# Función para cerrar la puerta
	
	# Cambia el estado a cerrada
	puerta_abierta = false
	
	# Reproduce la animación de cerrar
	anim.play("Cerrar")
	
	# Activa la colisión para bloquear el paso
	bloqueo.disabled = false  


func _on_body_entered(body):
	# Esta función se ejecuta cuando un cuerpo entra al área
	
	# Verifica que el objeto que entra sea el jugador
	if body.name == "Player":
		# Activa la interacción
		jugador_dentro = true
		

func _on_body_exited(body):
	# Esta función se ejecuta cuando un cuerpo sale del área
	
	# Verifica que el objeto que sale sea el jugador
	if body.name == "Player":
		# Desactiva la interacción
		jugador_dentro = false
