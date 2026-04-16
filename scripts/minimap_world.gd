extends Node2D

@onready var player_icon = $PlayerIcon
@onready var color_pantalla = $ColorRect
var player_real: Node2D
var rooms_visited = {}

var locks_node: Node2D

func _ready():
	# Cargar el registro de candados globales de niveles anteriores
	rooms_visited = GlobalState.rooms_visited
	
	if color_pantalla:
		color_pantalla.color = Color(0, 0, 0, 1) # negro sólido
		color_pantalla.size = Vector2(300, 200) # tamaño del minimapa
		color_pantalla.position = Vector2.ZERO
		
	locks_node = Node2D.new()
	locks_node.name = "Locks"
	locks_node.z_index = 50 # Asegurar que esten por encima de las rooms
	add_child(locks_node)
	
	for room in $Rooms.get_children():
		var lock_label = Label.new()
		lock_label.name = room.name
		lock_label.text = "🔒"
		lock_label.add_theme_font_size_override("font_size", 250)
		lock_label.position = room.position - Vector2(125, 125)
		locks_node.add_child(lock_label)

func _process(_delta):
	# 1. Si no tenemos jugador o el jugador actual ya no existe (cambio de nivel)
	if player_real == null or not is_instance_valid(player_real):
		_buscar_jugador_activo()
		return # Saltamos este frame hasta encontrarlo
	
	# 2. Si lo tenemos, actualizamos la posición
	if player_icon:
		var parent = player_real.get_parent()
		var closest_room: Node2D = null
		var min_dist = INF
		
		# Find the room the player is in within the real level
		if parent:
			for child in parent.get_children():
				if child.name.begins_with("Room") and child is Node2D:
					# Usamos el centro aproximado de la sala (1500 de ancho, 1016 de alto)
					# para que al cruzar la puerta el minimapa se habilite inmediatatamente
					var center_offset = Vector2(750, 508)
					var dist = player_real.global_position.distance_to(child.global_position + center_offset)
					if dist < min_dist:
						min_dist = dist
						closest_room = child
						
		if closest_room:
			rooms_visited[closest_room.name] = true
			
			var minimap_room = $Rooms.get_node_or_null(NodePath(closest_room.name))
			if minimap_room:
				var local_pos = player_real.global_position - closest_room.global_position
				player_icon.global_position = minimap_room.global_position + local_pos
			else:
				player_icon.position = player_real.global_position
		else:
			player_icon.position = player_real.global_position
			
		actualizar_candados()
			
		# Make the minimap camera follow the player
		if $Camera2D:
			$Camera2D.global_position = player_icon.global_position

func _buscar_jugador_activo():
	# Buscamos en todo el árbol de escenas al nodo llamado "Player"
	# Esto encontrará al Player del nivel que esté cargado actualmente
	var found_player = get_tree().root.find_child("Player", true, false)
	
	if found_player:
		player_real = found_player
		print("✅ Minimapa conectado con: ", player_real.get_parent().name, "/Player")

func actualizar_candados():
	if not locks_node:
		return
		
	for room in $Rooms.get_children():
		var lock = locks_node.get_node_or_null(NodePath(room.name))
		if lock:
			if rooms_visited.has(room.name):
				lock.visible = false # ya visitado → sin candado
				room.modulate = Color(1, 1, 1, 1) # Restaurar color
			else:
				lock.visible = true # no visitado → mostrar candado
				room.modulate = Color(0.15, 0.15, 0.15, 1) # Oscurecer habitación
