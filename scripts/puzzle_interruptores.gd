extends Node2D

signal puzzle_completado

# Orden correcto: 1, 2, 3 (Interruptor_1 primero, luego 2, luego 3)
var secuencia_correcta := [1, 2, 3]
var secuencia_actual := []
var resuelto := false

func interruptor_presionado(numero: int) -> void:
	if resuelto:
		return
	
	if "modo_prueba" in GlobalState and GlobalState.modo_prueba:
		resuelto = true
		GlobalState.resolver_puzzle(get_parent().name)
		emit_signal("puzzle_completado")
		print("🛡️ [Modo Prueba] Auto-resolviendo puzzle de interruptores!")
		for child in get_children():
			if child is Area2D and child.has_node("Sprite2D"):
				child.get_node("Sprite2D").modulate = Color(0.95, 0.75, 0.15, 1.0)
		return

	secuencia_actual.append(numero)
	print("Secuencia actual: ", secuencia_actual)
	
	# Verificar si el último presionado es correcto
	var pos = secuencia_actual.size() - 1
	if secuencia_actual[pos] != secuencia_correcta[pos]:
		print("❌ Orden incorrecto, reiniciando...")
		reiniciar()
		return
	
	# Si completó toda la secuencia correcta
	if secuencia_actual.size() == secuencia_correcta.size():
		resuelto = true
		GlobalState.resolver_puzzle(get_parent().name)
		emit_signal("puzzle_completado")
		print("🎉 ¡Secuencia correcta! Puzzle resuelto")

func reiniciar() -> void:
	secuencia_actual = []
	# Resetear color de todos los interruptores
	for child in get_children():
		if child is Area2D:
			child.get_node("Sprite2D").modulate = Color(1, 1, 1)


func _on_interruptor_1_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		$Interruptor_1.jugador_cerca = true

func _on_interruptor_1_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		$Interruptor_1.jugador_cerca = false

func _on_interruptor_2_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		$Interruptor_2.jugador_cerca = true

func _on_interruptor_2_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		$Interruptor_2.jugador_cerca = false

func _on_interruptor_3_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		$Interruptor_3.jugador_cerca = true

func _on_interruptor_3_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		$Interruptor_3.jugador_cerca = false
