extends Control

# Ruta de la escena del primer nivel, usada al iniciar una partida nueva
const FIRST_LEVEL = "res://scenes/Nivel_1.tscn"

func _ready() -> void:
	# Permite que este menú siga funcionando aunque el árbol esté pausado
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	show_menu()

func show_menu():
	# Hace visible el menú y pausa el juego
	show()
	var tree = get_tree()
	if tree:
		tree.paused = true

func hide_menu():
	# Reanuda el juego y oculta el menú
	var tree = get_tree()
	if tree:
		tree.paused = false
	hide()

func _on_salir_pressed() -> void:
	# Cierra la aplicación completamente
	var tree = get_tree()
	if tree:
		tree.quit()

func _on_continuar_pressed() -> void:
	hide_menu()

	# Espera un frame para asegurarse de que el árbol esté despaused antes de cambiar de escena
	await get_tree().process_frame

	# Si existe una partida guardada, la carga; si no, inicia desde el primer nivel
	if GlobalState.has_method("has_save_game") and GlobalState.has_save_game():
		GlobalState.load_game()
		print("▶️ Continuando partida")
	else:
		get_tree().change_scene_to_file(FIRST_LEVEL)
		print("🆕 Nueva partida iniciada")

func _on_play_pressed() -> void:
	# Oculta el menú, despausa el juego y carga el primer nivel directamente
	hide_menu()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Nivel_1.tscn")

func _on_reiniciar_partidas_pressed() -> void:
	# Borra el guardado existente si GlobalState tiene el método disponible
	if GlobalState.has_method("delete_save"):
		GlobalState.delete_save()

	# Despausa el juego y reinicia desde el primer nivel con el estado limpio
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Nivel_1.tscn")
