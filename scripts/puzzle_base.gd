extends Node2D

signal puzzle_completado

@export var nombre_habitacion: String = ""

var resuelto := false

func _on_puzzle_resuelto() -> void:
	if resuelto:
		return
	resuelto = true
	if nombre_habitacion != "":
		GlobalState.resolver_puzzle(nombre_habitacion)
	emit_signal("puzzle_completado")
	print("🎉 Puzzle completado en: ", nombre_habitacion)
