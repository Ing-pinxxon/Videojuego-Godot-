extends Control

# Ruta de la escena del primer nivel, usada al iniciar una partida nueva
const FIRST_LEVEL = "res://scenes/Nivel_1.tscn"

func _ready() -> void:
	# Permite que este menú siga funcionando aunque el árbol esté pausado
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	show_menu()
	
	# Crear el botón de MODO PRUEBA dinámicamente para evitar cualquier corrupción en la escena tscn
	var btn_prueba = Button.new()
	btn_prueba.name = "ModoPrueba"
	btn_prueba.text = "MODO PRUEBA"
	btn_prueba.icon = preload("res://assets/ui/Boton.png")
	btn_prueba.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_prueba.add_theme_font_size_override("font_size", 24)
	# Un hermoso color dorado distintivo
	btn_prueba.add_theme_color_override("font_color", Color(0.95, 0.75, 0.15, 1.0))
	
	var container = get_node_or_null("TextureRect/VBoxContainer")
	if container:
		container.add_child(btn_prueba)
		# Lo posicionamos justo antes del botón "SALIR" (el cual estará en el último índice)
		var index_salir = container.get_child_count() - 2
		if index_salir >= 0:
			container.move_child(btn_prueba, index_salir)
	
	# Conectamos la señal
	btn_prueba.pressed.connect(_on_modo_prueba_pressed)

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
	# Desactivamos el modo prueba para la partida normal
	if "modo_prueba" in GlobalState:
		GlobalState.modo_prueba = false
	
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
	# Desactivamos el modo prueba para la partida normal
	if "modo_prueba" in GlobalState:
		GlobalState.modo_prueba = false
		
	# Oculta el menú, despausa el juego y carga el primer nivel directamente
	hide_menu()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Nivel_1.tscn")

func _on_reiniciar_partidas_pressed() -> void:
	# Desactivamos el modo prueba para la partida normal
	if "modo_prueba" in GlobalState:
		GlobalState.modo_prueba = false
		
	# Borra el guardado existente si GlobalState tiene el método disponible
	if GlobalState.has_method("delete_save"):
		GlobalState.delete_save()

	# Despausa el juego y reinicia desde el primer nivel con el estado limpio
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Nivel_1.tscn")

func _on_modo_prueba_pressed() -> void:
	# Activamos el modo prueba (Inmortalidad + Kills de 1 golpe)
	if "modo_prueba" in GlobalState:
		GlobalState.modo_prueba = true
		print("🛡️ MODO PRUEBA ACTIVADO: Inmortalidad completa y Kills de 1 golpe activas.")
		
	hide_menu()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Nivel_1.tscn")
