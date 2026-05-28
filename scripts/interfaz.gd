extends Control

const FIRST_LEVEL = "res://scenes/Nivel_1.tscn"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	show_menu()


func show_menu():
	show()
	
	var tree = get_tree()
	if tree:
		tree.paused = true


func hide_menu():
	var tree = get_tree()
	if tree:
		tree.paused = false
	
	hide()


func _on_salir_pressed() -> void:
	var tree = get_tree()
	
	if tree:
		tree.quit()


func _on_guardar_pressed() -> void:
	if GlobalState.has_method("save_game"):
		GlobalState.save_game()
		print("✅ Guardado con éxito")


func _on_continuar_pressed() -> void:
	hide_menu()


func _on_play_pressed() -> void:
	hide_menu()
	
	await get_tree().process_frame
	
	if GlobalState.has_method("has_save_game") and GlobalState.has_save_game():
		GlobalState.load_game()
		print("▶️ Continuando partida")
	else:
		get_tree().change_scene_to_file(FIRST_LEVEL)
		print("🆕 Nueva partida iniciada")


func _on_reiniciar_pressed() -> void:
	if GlobalState.has_method("delete_save"):
		GlobalState.delete_save()
	
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Nivel_1.tscn")
