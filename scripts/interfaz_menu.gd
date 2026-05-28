extends Control

# Referencia al Label que muestra el mensaje de notificación al jugador
@onready var notificacion: Label = $Notificacion

func _ready() -> void:
	# Permite que este nodo siga procesando aunque el árbol esté pausado
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	show_menu()

func show_menu():
	# Hace visible el menú y pausa el juego
	show()
	get_tree().paused = true

func hide_menu():
	# Reanuda el juego y oculta el menú
	get_tree().paused = false
	hide()

func _on_salir_pressed() -> void:
	# Cierra la aplicación completamente
	get_tree().quit()

func _on_guardar_pressed() -> void:
	# Llama al sistema de guardado de GlobalState si el método existe,
	# luego muestra una notificación confirmando la acción al jugador
	if GlobalState.has_method("save_game"):
		GlobalState.save_game()
		mostrar_notificacion("Partida guardada")

func _on_continuar_pressed() -> void:
	# Cierra el menú y devuelve el control al jugador
	hide_menu()

# ── NOTIFICACIÓN ─────────────────────────────────────────
func mostrar_notificacion(texto: String) -> void:
	# Asigna el texto recibido y hace visible el Label con opacidad total
	notificacion.text = texto
	notificacion.modulate.a = 1.0
	notificacion.visible = true

	# Crea un Tween para animar la desaparición del mensaje
	var tween = create_tween()

	# Paso 1: mantiene el mensaje visible durante 1.2 segundos
	tween.tween_interval(1.2)

	# Paso 2: reduce la opacidad a 0 en 0.8 segundos (efecto fade out)
	tween.tween_property(notificacion, "modulate:a", 0.0, 0.8)

	# Paso 3: oculta el Label una vez que la animación termina
	tween.tween_callback(func(): notificacion.visible = false)
