extends Node2D

# ======================================================
# SEÑALES
# ======================================================

# Señal que se emite cuando el puzzle es completado
signal puzzle_completado


# ======================================================
# VARIABLES
# ======================================================

# Cantidad de plataformas actualmente activas
var plataformas_activas := 0

# Cantidad total de plataformas necesarias
# para resolver el puzzle
var total_plataformas := 0

# Indica si el puzzle ya fue resuelto
var resuelto := false


# ======================================================
# FUNCIÓN READY
# ======================================================

func _ready():

	# Recorre todos los hijos del nodo actual
	for child in get_children():

		# Verifica cuáles nodos son plataformas de presión
		if child.name.contains("PlataformaPresion"):

			# Incrementa el total de plataformas necesarias
			total_plataformas += 1


# ======================================================
# FUNCIÓN CUANDO UNA PLATAFORMA SE ACTIVA
# ======================================================

func plataforma_activada() -> void:

	# Incrementa el contador de plataformas activas
	plataformas_activas += 1

	# Muestra información en consola
	print("Plataformas activas: ", plataformas_activas, "/", total_plataformas)

	# Verifica si el puzzle fue completado
	verificar()


# ======================================================
# FUNCIÓN CUANDO UNA PLATAFORMA SE DESACTIVA
# ======================================================

func plataforma_desactivada() -> void:

	# Reduce la cantidad de plataformas activas
	plataformas_activas -= 1

	# Marca el puzzle nuevamente como no resuelto
	resuelto = false

	# Mensaje de depuración en consola
	print("Objeto retirado, puzzle bloqueado de nuevo")


# ======================================================
# FUNCIÓN PARA VERIFICAR EL ESTADO DEL PUZZLE
# ======================================================

func verificar() -> void:

	# Comprueba si todas las plataformas están activas
	# y además el puzzle aún no ha sido resuelto
	if plataformas_activas >= total_plataformas and not resuelto:

		# Marca el puzzle como resuelto
		resuelto = true

		# Guarda el estado del puzzle utilizando GlobalState
		GlobalState.resolver_puzzle(get_parent().name)

		# Emite la señal indicando que el puzzle fue completado
		emit_signal("puzzle_completado")

		# Mensaje de éxito en consola
		print("🎉 ¡Todos los objetos en su lugar! Puzzle resuelto")
