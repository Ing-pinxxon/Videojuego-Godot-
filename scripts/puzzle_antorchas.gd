extends Node2D

signal puzzle_completado

var secuencia_correcta := [1, 2, 3]
var secuencia_actual := []
var resuelto := false

func antorcha_encendida(numero: int) -> void:
	if resuelto:
		return

	secuencia_actual.append(numero)
	print("Secuencia: ", secuencia_actual)

	var pos = secuencia_actual.size() - 1
	if secuencia_actual[pos] != secuencia_correcta[pos]:
		print("❌ Orden incorrecto, apagando antorchas...")
		reiniciar()
		return

	if secuencia_actual.size() == secuencia_correcta.size():
		resuelto = true
		GlobalState.resolver_puzzle(get_parent().name)
		emit_signal("puzzle_completado")
		print("🔥 ¡Antorchas encendidas en orden! Puzzle resuelto")

func reiniciar() -> void:
	secuencia_actual = []
	print("🔄 Secuencia reiniciada")
	for child in get_children():
		if child is Area2D:
			child.apagar()


func _on_antorcha_1_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		$Antorcha_1.jugador_cerca = true

func _on_antorcha_1_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		$Antorcha_1.jugador_cerca = false

func _on_antorcha_2_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		$Antorcha_2.jugador_cerca = true

func _on_antorcha_2_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		$Antorcha_2.jugador_cerca = false

func _on_antorcha_3_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		$Antorcha_3.jugador_cerca = true

func _on_antorcha_3_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		$Antorcha_3.jugador_cerca = false
