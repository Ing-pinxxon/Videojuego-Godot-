extends Node

# Flag global para el modo prueba (Inmortalidad + Kills de 1 golpe)
var modo_prueba: bool = false

# Habitaciones que el jugador ha visitado (clave: nombre de sala, valor: true)
var rooms_visited = {}

# Ruta del archivo donde se almacena la partida guardada
var ruta: String = "user://game_data.dat"

# Diccionario central que contiene todos los datos serializables de la partida
var Datos: Dictionary = {}

# Indica si hay datos pendientes de aplicar tras cargar una escena
var should_load_game: bool = false

# Lista de IDs de enemigos que han sido derrotados en la partida actual
var enemigos_derrotados: Array = []


# ── PUZZLES ──────────────────────────────────────────────

# Diccionario que registra qué puzzles han sido resueltos (clave: nombre de habitación)
var puzzles_resueltos := {}

# Marca un puzzle como resuelto usando el nombre de su habitación como clave
func resolver_puzzle(nombre_habitacion: String) -> void:
	puzzles_resueltos[nombre_habitacion] = true
	print("✅ Puzzle resuelto en: ", nombre_habitacion)

# Devuelve true si el puzzle de la habitación indicada ya fue resuelto
func puzzle_esta_resuelto(nombre_habitacion: String) -> bool:
	if modo_prueba:
		return true
	return puzzles_resueltos.get(nombre_habitacion, false)


# ── SISTEMA DE GUARDADO/CARGA (SAVE/LOAD) ────────────────

# Devuelve true si existe un archivo de guardado en disco
func has_save_game() -> bool:
	return FileAccess.file_exists(ruta)

# Agrega el ID de un enemigo a la lista de derrotados si no estaba ya registrado
func registrar_enemigo_derrotado(enemy_id: String) -> void:
	if enemy_id == "":
		return
	if not enemy_id in enemigos_derrotados:
		enemigos_derrotados.append(enemy_id)
		print("💀 Enemigo derrotado registrado: ", enemy_id)

func save_game() -> void:
	# Verifica que haya una escena activa desde la cual guardar
	var level_root = get_tree().current_scene
	if not level_root:
		print("❌ No hay escena activa para guardar.")
		return

	# Busca al jugador dentro del grupo "player"
	var player = null
	for node in get_tree().get_nodes_in_group("player"):
		if node is CharacterBody2D and node.name == "Player":
			player = node
			break

	if not player:
		print("❌ No se encontró al jugador para guardar la partida.")
		return

	# Serializa los datos del jugador y del nivel actual
	Datos["level_scene"]      = level_root.scene_file_path
	Datos["player_position"]  = {
		"x": player.global_position.x,
		"y": player.global_position.y
	}
	Datos["player_health"]       = player.health
	Datos["enemigos_derrotados"] = enemigos_derrotados
	Datos["puzzles_resueltos"]   = puzzles_resueltos

	# Recorre todos los enemigos activos en la escena y guarda su estado
	var enemies_data = {}
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if not is_instance_valid(enemy) or not enemy is Enemy:
			continue
		if enemy.enemy_id == "":
			print("⚠️ Enemigo sin ID, no se guardará: ", enemy.name)
			continue
		enemies_data[enemy.enemy_id] = {
			"position": {
				"x": enemy.global_position.x,
				"y": enemy.global_position.y
			},
			"health": enemy.health
		}
	Datos["enemies"]       = enemies_data
	Datos["rooms_visited"] = rooms_visited

	# Escribe el diccionario serializado como JSON en el archivo de guardado
	var file = FileAccess.open(ruta, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(Datos))
		file.close()
		print("💾 Partida guardada con éxito en: ", ruta)
	else:
		print("❌ Error al escribir el archivo de guardado en: ", ruta)

func load_game() -> void:
	# Verifica que el archivo de guardado exista antes de intentar leerlo
	if not FileAccess.file_exists(ruta):
		print("⚠️ No hay archivo de guardado disponible.")
		return

	var file = FileAccess.open(ruta, FileAccess.READ)
	if not file:
		print("❌ Error al abrir el archivo de guardado para lectura.")
		return

	var json_string = file.get_as_text()
	file.close()

	# Parsea el JSON leído y verifica que no haya errores de formato
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		print("❌ Error parseando los datos de guardado JSON.")
		return

	# Almacena los datos y activa la bandera para aplicarlos al cargar la escena
	Datos            = json.data
	should_load_game = true

	# Restaura el estado global inmediatamente (antes de cambiar de escena)
	enemigos_derrotados = Datos.get("enemigos_derrotados", [])
	puzzles_resueltos   = Datos.get("puzzles_resueltos", {})
	rooms_visited       = Datos.get("rooms_visited", {})

	# Cambia a la escena guardada; apply_load_game() se encargará del resto
	var saved_level = Datos.get("level_scene", "")
	if saved_level != "":
		print("🔄 Cargando nivel guardado: ", saved_level)
		get_tree().change_scene_to_file(saved_level)
	else:
		print("❌ Error: No se especificó escena en los datos guardados.")

# Aplica los datos cargados al jugador y a los enemigos una vez que la escena está lista.
# Debe llamarse desde el _ready() del jugador cuando should_load_game sea true.
func apply_load_game(player: CharacterBody2D) -> void:
	if not should_load_game or Datos.is_empty():
		return

	print("📂 Aplicando datos cargados al jugador y enemigos...")

	# 1. Restaurar posición y salud del jugador
	var pos_data = Datos.get("player_position", {"x": 0.0, "y": 0.0})
	player.global_position = Vector2(pos_data["x"], pos_data["y"])
	player.health = Datos.get("player_health", player.max_health)
	if player.has_method("_update_hearts"):
		player._update_hearts()

	# 2. Restaurar o eliminar enemigos según su estado guardado
	var enemies     = player.get_tree().get_nodes_in_group("enemies")
	var saved_enemies = Datos.get("enemies", {})

	for enemy_node in enemies:
		if not is_instance_valid(enemy_node) or not enemy_node is Enemy:
			continue

		var enemy: Enemy = enemy_node

		# Si el enemigo fue derrotado en la partida guardada, se elimina de la escena
		if enemy.enemy_id != "" and enemy.enemy_id in enemigos_derrotados:
			print("🗑️ Eliminando enemigo derrotado: ", enemy.enemy_id)
			enemy.is_dead = true
			enemy.queue_free()
			continue

		# Restaura posición y salud del enemigo si tiene datos guardados
		if enemy.enemy_id in saved_enemies:
			var enemy_data = saved_enemies[enemy.enemy_id]
			var e_pos = enemy_data.get("position", {})
			if not e_pos.is_empty():
				enemy.global_position = Vector2(e_pos["x"], e_pos["y"])
			enemy.health = enemy_data.get("health", enemy.max_health)

			# Desactiva temporalmente el daño mientras el enemigo se reposiciona
			enemy.is_loading = true
			enemy.can_damage = false
			var enemy_ref = enemy
			get_tree().create_timer(0.3).timeout.connect(func():
				if is_instance_valid(enemy_ref):
					enemy_ref.is_loading = false
					enemy_ref.can_damage = true
			)

			if enemy.has_method("_update_hearts"):
				enemy._update_hearts()

	# Marca la carga como completada para no volver a aplicarla
	should_load_game = false
	print("✅ Partida cargada y aplicada con éxito!")


# ── ELIMINAR GUARDADO ────────────────────────────────────

func delete_save() -> void:
	# Elimina el archivo físico del disco si existe
	if FileAccess.file_exists(ruta):
		DirAccess.remove_absolute(ruta)
		print("🗑️ Archivo de guardado eliminado")

	# Limpia todo el estado en memoria para dejar el GlobalState como nuevo
	Datos.clear()
	enemigos_derrotados.clear()
	puzzles_resueltos.clear()
	rooms_visited.clear()
	should_load_game = false
	print("✨ Estado de partida en memoria limpiado")
