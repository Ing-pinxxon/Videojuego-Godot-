extends Area2D

# ======================================================
# REFERENCIAS A NODOS
# ======================================================

# Referencia al Sprite2D hijo
# Se utiliza para cambiar el color visual de la plataforma
@onready var sprite = $Sprite2D


# ======================================================
# FUNCIÓN READY
# ======================================================

func _ready():

	# Conecta la señal cuando un cuerpo entra al área
	body_entered.connect(_on_body_entered)

	# Conecta la señal cuando un cuerpo sale del área
	body_exited.connect(_on_body_exited)


# ======================================================
# CUANDO UN CUERPO ENTRA AL ÁREA
# ======================================================

func _on_body_entered(body):

	# Verifica si el cuerpo que entró
	# corresponde a un objeto empujable
	if body.name.contains("ObjetoEmpujable"):

		# Busca el nodo del jugador utilizando el grupo "player"
		var player = get_tree().get_first_node_in_group("player")

		# Verifica que exista el jugador
		# y que esté cargando exactamente este objeto
		if player and player.objeto_cargado == body:

			# Obliga al jugador a soltar el objeto
			player.soltar_objeto()

		# Cambia el color del sprite a verde
		# para indicar que la plataforma está activada
		sprite.modulate = Color(0, 1, 0)

		# Llama a la función del nodo padre
		# para activar la plataforma
		get_parent().plataforma_activada()


# ======================================================
# CUANDO UN CUERPO SALE DEL ÁREA
# ======================================================

func _on_body_exited(body):

	# Verifica si el cuerpo que salió
	# corresponde a un objeto empujable
	if body.name.contains("ObjetoEmpujable"):

		# Restaura el color original del sprite
		sprite.modulate = Color(1, 1, 1)

		# Llama a la función del nodo padre
		# para desactivar la plataforma
		get_parent().plataforma_desactivada()
