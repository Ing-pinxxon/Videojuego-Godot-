extends Node2D

# ======================================================
# SEÑALES
# ======================================================

# Señal que se emite cuando el puzzle es completado
signal puzzle_completado


# ======================================================
# VARIABLES
# ======================================================

# Secuencia correcta que el jugador debe seguir
# para resolver el puzzle
var secuencia_correcta := [1, 2, 3]

# Guarda la secuencia actual ingresada por el jugador
var secuencia_actual := []

# Indica si el puzzle ya fue resuelto
var resuelto := false


# ======================================================
# FUNCIÓN CUANDO UNA ANTORCHA SE ENCIENDE
# ======================================================

func antorcha_encendida(numero: int) -> void:

	# Si el puzzle ya fue resuelto,
	# no se ejecuta nuevamente la lógica
	if resuelto:
		return

	# Agrega el número de la antorcha
	# a la secuencia actual

	secuencia_actual.append(numero)

	# Muestra la secuencia actual en consola
	print("Secuencia: ", secuencia_actual)

	# Obtiene la posición del último elemento agregado
	var pos = secuencia_actual.size() - 1

	# Verifica si el número ingresado coincide
	# con la secuencia correcta
	if secuencia_actual[pos] != secuencia_correcta[pos]:

		# Mensaje de error en consola
		print("❌ Orden incorrecto, apagando antorchas...")

		# Reinicia el puzzle
		reiniciar()
		return

	# Verifica si toda la secuencia fue completada correctamente
	if secuencia_actual.size() == secuencia_correcta.size():

		# Marca el puzzle como resuelto
		resuelto = true

		# Guarda el estado del puzzle en GlobalState
		GlobalState.resolver_puzzle(get_parent().name)

		# Emite la señal indicando que el puzzle fue completado
		emit_signal("puzzle_completado")

		# Mensaje de éxito en consola
		print("🔥 ¡Antorchas encendidas en orden! Puzzle resuelto")


# ======================================================
# FUNCIÓN PARA REINICIAR EL PUZZLE
# ======================================================

func reiniciar() -> void:

	# Limpia la secuencia actual
	secuencia_actual = []

	# Mensaje en consola
	print("🔄 Secuencia reiniciada")

	# Recorre todos los hijos del nodo
	for child in get_children():

		# Verifica si el nodo es un Area2D
		if child is Area2D:

			# Apaga cada antorcha
			child.apagar()


# ======================================================
# ANTORCHA 1 - ENTRADA DEL JUGADOR
# ======================================================

func _on_antorcha_1_body_entered(body: Node2D) -> void:

	# Verifica si el cuerpo corresponde al jugador
	if body.name == "Player" or body.is_in_group("player"):

		# Indica que el jugador está cerca de la antorcha 1
		$Antorcha_1.jugador_cerca = true


# ======================================================
# ANTORCHA 1 - SALIDA DEL JUGADOR
# ======================================================

func _on_antorcha_1_body_exited(body: Node2D) -> void:

	# Verifica si el cuerpo corresponde al jugador
	if body.name == "Player" or body.is_in_group("player"):

		# Indica que el jugador ya no está cerca de la antorcha 1
		$Antorcha_1.jugador_cerca = false


# ======================================================
# ANTORCHA 2 - ENTRADA DEL JUGADOR
# ======================================================

func _on_antorcha_2_body_entered(body: Node2D) -> void:

	# Verifica si el cuerpo corresponde al jugador
	if body.name == "Player" or body.is_in_group("player"):

		# Indica que el jugador está cerca de la antorcha 2
		$Antorcha_2.jugador_cerca = true


# ======================================================
# ANTORCHA 2 - SALIDA DEL JUGADOR
# ======================================================

func _on_antorcha_2_body_exited(body: Node2D) -> void:

	# Verifica si el cuerpo corresponde al jugador
	if body.name == "Player" or body.is_in_group("player"):

		# Indica que el jugador ya no está cerca de la antorcha 2
		$Antorcha_2.jugador_cerca = false


# ======================================================
# ANTORCHA 3 - ENTRADA DEL JUGADOR
# ======================================================

func _on_antorcha_3_body_entered(body: Node2D) -> void:

	# Verifica si el cuerpo corresponde al jugador
	if body.name == "Player" or body.is_in_group("player"):

		# Indica que el jugador está cerca de la antorcha 3
		$Antorcha_3.jugador_cerca = true


# ======================================================
# ANTORCHA 3 - SALIDA DEL JUGADOR
# ======================================================

func _on_antorcha_3_body_exited(body: Node2D) -> void:

	# Verifica si el cuerpo corresponde al jugador
	if body.name == "Player" or body.is_in_group("player"):

		# Indica que el jugador ya no está cerca de la antorcha 3
		$Antorcha_3.jugador_cerca = false
