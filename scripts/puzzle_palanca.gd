extends Node2D

signal puzzle_completado

@export var total_palancas: int = 1

var palancas_activadas := 0
var resuelto := false

func palanca_activada() -> void:
	palancas_activadas += 1
	print("Palancas: ", palancas_activadas, "/", total_palancas)
	if "modo_prueba" in GlobalState and GlobalState.modo_prueba:
		resuelto = true
		GlobalState.resolver_puzzle(get_parent().name)
		emit_signal("puzzle_completado")
		print("🛡️ [Modo Prueba] Auto-resolviendo puzzle de palanca!")
		return
	if palancas_activadas >= total_palancas and not resuelto:
		resuelto = true
		GlobalState.resolver_puzzle(get_parent().name)
		emit_signal("puzzle_completado")
		print("🎉 ¡Puzzle resuelto!")

func palanca_desactivada() -> void:
	palancas_activadas = max(0, palancas_activadas - 1)
