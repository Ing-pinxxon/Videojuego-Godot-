extends Area2D

# ======================================================
# VARIABLES EXPORTADAS
# ======================================================

# Número identificador de la antorcha
# Se puede modificar desde el editor de Godot
@export var numero: int = 1


# ======================================================
# VARIABLES DE CONTROL
# ======================================================

# Indica si el jugador está cerca de la antorcha
var jugador_cerca := false

# Indica si la antorcha está encendida
var encendida := false


# ======================================================
# REFERENCIAS A NODOS
# ======================================================

# Referencia al nodo Sprite2D o AnimatedSprite2D
# encargado de mostrar las animaciones
@onready var sprite = $Sprite2D


# ======================================================
# FUNCIÓN READY
# ======================================================

func _ready():

	# Apaga la antorcha al iniciar la escena
	apagar()


# ======================================================
# PROCESS
# ======================================================

func _process(_delta):

	# Verifica si el jugador está cerca
	# y si presionó la tecla de interacción
	if jugador_cerca and Input.is_action_just_pressed("ui_accept"):

		# Enciende la antorcha únicamente
		# si aún no está encendida
		if not encendida:
			encender()


# ======================================================
# FUNCIÓN PARA ENCENDER LA ANTORCHA
# ======================================================

func encender() -> void:

	# Marca la antorcha como encendida
	encendida = true

	# Reproduce la animación de antorcha encendida
	sprite.play("encendida")

	# Mensaje en consola
	print("🔥 Antorcha ", numero, " encendida")

	# Notifica al nodo padre que esta antorcha fue activada
	get_parent().antorcha_encendida(numero)


# ======================================================
# FUNCIÓN PARA APAGAR LA ANTORCHA
# ======================================================

func apagar() -> void:

	# Marca la antorcha como apagada
	encendida = false

	# Reproduce la animación de antorcha apagada
	sprite.play("apagada")

	# Mensaje en consola
	print("💀 Antorcha ", numero, " apagada")


# ======================================================
# CUANDO UN CUERPO ENTRA AL ÁREA
# ======================================================

func _on_body_entered(body):

	# Verifica si el cuerpo que entró
	# corresponde al jugador
	if body.name == "Player" or body.is_in_group("player"):

		# Indica que el jugador está cerca
		jugador_cerca = true


# ======================================================
# CUANDO UN CUERPO SALE DEL ÁREA
# ======================================================

func _on_body_exited(body):

	# Verifica si el cuerpo que salió
	# corresponde al jugador
	if body.name == "Player" or body.is_in_group("player"):

		# Indica que el jugador ya no está cerca
		jugador_cerca = false
