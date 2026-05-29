extends CharacterBody2D

# ======================================================
# VARIABLES
# ======================================================

# Indica si el objeto está siendo cargado por el jugador
var siendo_cargado := false

# Guarda la referencia del personaje que está cargando el objeto
var portador = null


# ======================================================
# FUNCIÓN READY
# ======================================================

func _ready():
	# Agrega este objeto al grupo "empujable"
	# para poder identificarlo fácilmente desde otros scripts
	add_to_group("empujable")


# ======================================================
# PHYSICS PROCESS
# ======================================================

func _physics_process(_delta):

	# Verifica si el objeto está siendo cargado
	# y además existe un portador válido
	if siendo_cargado and portador:

		# Mantiene el objeto en la posición del portador
		# con un desplazamiento hacia arriba
		global_position = portador.global_position + Vector2(0, -20)

		# Detiene cualquier movimiento físico
		velocity = Vector2.ZERO

	else:
		# Movimiento normal del CharacterBody2D
		move_and_slide()

		# Reinicia la velocidad para evitar desplazamientos
		velocity = Vector2.ZERO


# ======================================================
# FUNCIÓN PARA RECOGER EL OBJETO
# ======================================================

func ser_recogido(quien):

	# Marca el objeto como cargado
	siendo_cargado = true

	# Guarda quién está cargando el objeto
	portador = quien

	# Desactiva la capa de colisión
	# para evitar que empuje al jugador
	set_collision_layer_value(1, false)

	# Desactiva la máscara de colisión
	set_collision_mask_value(1, false)


# ======================================================
# FUNCIÓN PARA SOLTAR EL OBJETO
# ======================================================

func ser_soltado():

	# Marca el objeto como no cargado
	siendo_cargado = false

	# Elimina la referencia del portador
	portador = null

	# Reactiva la capa de colisión
	set_collision_layer_value(1, true)

	# Reactiva la máscara de colisión
	set_collision_mask_value(1, true)
