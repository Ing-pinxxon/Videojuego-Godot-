extends Node2D

signal puzzle_completado

var plataformas_activas := 0
var total_plataformas := 0
var resuelto := false

func _ready():
	# Contar cuántas plataformas hay en la escena
	for child in get_children():
		if child.name.contains("PlataformaPresion"):
			total_plataformas += 1

func plataforma_activada() -> void:
	plataformas_activas += 1
	print("Plataformas activas: ", plataformas_activas, "/", total_plataformas)
	verificar()

func plataforma_desactivada() -> void:
	plataformas_activas -= 1
	resuelto = false
	print("Objeto retirado, puzzle bloqueado de nuevo")

func verificar() -> void:
	if plataformas_activas >= total_plataformas and not resuelto:
		resuelto = true
		GlobalState.resolver_puzzle(get_parent().name)
		emit_signal("puzzle_completado")
		print("🎉 ¡Todos los objetos en su lugar! Puzzle resuelto")
