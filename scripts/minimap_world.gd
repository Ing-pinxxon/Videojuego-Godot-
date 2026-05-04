extends Node2D
# Este script controla el minimapa, la posición del jugador en él
# y el sistema de habitaciones visitadas con candados

@onready var player_icon = $PlayerIcon
# Referencia al icono que representa al jugador en el minimapa


@onready var color_pantalla = $ColorRect
# Referencia a un rectángulo de color (fondo del minimapa)

var player_real: Node2D
# Referencia al jugador real en el mundo principal

var rooms_visited = {}
# Diccionario que guarda las habitaciones visitadas (clave: nombre de sala, valor: true)

var locks_node: Node2D
# Nodo que contendrá todos los iconos de candado

func _ready():
	# Se ejecuta al iniciar la escena
	
	rooms_visited = GlobalState.rooms_visited
	# Carga las habitaciones visitadas desde un estado global
	
	if color_pantalla:
		# Configura el fondo del minimapa si existe
		
		color_pantalla.color = Color(0, 0, 0, 1)
		# Color negro completamente opaco
		
		color_pantalla.size = Vector2(300, 200) 
		# Tamaño del fondo del minimapa
		
		color_pantalla.position = Vector2.ZERO
		# Posición en (0,0)
		
	locks_node = Node2D.new()
	# Crea un nodo vacío para almacenar los candados
	
	locks_node.name = "Locks"
	# Nombre del nodo
	
	locks_node.z_index = 50 
	# Se asegura de que los candados se dibujen por encima
	
	add_child(locks_node)
	# Lo agrega como hijo del minimapa
	
	for room in $Rooms.get_children():
		# Recorre todas las salas del minimapa
		
		# Limpiar enemigos del minimapa (evita que se vean)
		var enemies_to_remove = room.find_children("*", "Node2D", true)
		for child in enemies_to_remove:
			if child.is_in_group("enemies") or child.name.contains("Enemy"):
				child.queue_free()
		
		var lock_label = Label.new()
		# Crea un Label para representar el candado
		
		lock_label.name = room.name
		# El nombre del candado será igual al de la sala
		
		lock_label.text = "🔒"
		# Icono visual del candado
		
		lock_label.add_theme_font_size_override("font_size", 250)
		# Tamaño grande del icono
		
		lock_label.position = room.position - Vector2(125, 125)
		# Ajusta la posición para centrar el candado sobre la sala
		
		locks_node.add_child(lock_label)
		# Añade el candado al nodo de candados

func _process(_delta):
	# Se ejecuta en cada frame
	
	if player_real == null or not is_instance_valid(player_real):
		# Si no hay referencia válida al jugador
		
		_buscar_jugador_activo()
		# Intenta encontrarlo en la escena
		
		return 

	if player_icon:
		# Si el icono del jugador existe
		
		var parent = player_real.get_parent()
		# Obtiene el nodo padre del jugador (donde están las rooms)
		
		var closest_room: Node2D = null
		# Variable para almacenar la sala más cercana
		
		var min_dist = INF
		# Distancia mínima inicial infinita
		
		if parent:
			# Si el jugador tiene padre
			
			for child in parent.get_children():
				# Recorre todos los hijos del padre
				
				if child.name.begins_with("Room") and child is Node2D and not child.name.begins_with("Enemy"):
					# Filtra solo nodos que sean salas
					
					var center_offset = Vector2(750, 508)
					# Offset para ajustar el centro de la sala
					
					var dist = player_real.global_position.distance_to(child.global_position + center_offset)
					# Calcula la distancia del jugador al centro de la sala
					
					if dist < min_dist:
						# Si es la sala más cercana encontrada
						
						min_dist = dist
						closest_room = child
						
		if closest_room:
			# Si encontró una sala cercana
			
			rooms_visited[closest_room.name] = true
			# Marca la sala como visitada
			
			var minimap_room = $Rooms.get_node_or_null(NodePath(closest_room.name))
			# Busca la sala equivalente en el minimapa
			
			if minimap_room:
				# Si existe en el minimapa
				
				var local_pos = player_real.global_position - closest_room.global_position
				# Calcula la posición local del jugador dentro de la sala
				
				player_icon.global_position = minimap_room.global_position + local_pos
				# Posiciona el icono en el minimapa respetando esa posición relativa
			else:
				player_icon.position = player_real.global_position
				# Si no encuentra la sala, usa la posición global directamente
		else:
			player_icon.position = player_real.global_position
			# Si no hay sala cercana, usa la posición global
		
		actualizar_candados()
		# Actualiza el estado visual de los candados
		
		if $Camera2D:
			# Si existe una cámara en el minimapa
			
			$Camera2D.global_position = player_icon.global_position
			# Hace que la cámara siga al icono del jugador

func _buscar_jugador_activo():
	# Busca el jugador en toda la escena
	
	var found_player = get_tree().root.find_child("Player", true, false)
	# Busca un nodo llamado "Player" de forma recursiva
	
	if found_player:
		player_real = found_player
		# Guarda la referencia
		
		print("✅ Minimapa conectado con: ", player_real.get_parent().name, "/Player")
		# Mensaje de confirmación en consola

func actualizar_candados():
	# Actualiza la visibilidad de los candados según salas visitadas
	
	if not locks_node:
		# Si no existe el nodo de candados
		return
		
	for room in $Rooms.get_children():
		# Recorre todas las salas del minimapa
		
		var lock = locks_node.get_node_or_null(NodePath(room.name))
		# Busca el candado correspondiente a la sala
		
		if lock:
			if rooms_visited.has(room.name):
				# Si la sala ya fue visitada
				
				lock.visible = false 
				# Oculta el candado
				
				room.modulate = Color(1, 1, 1, 1) 
				# Muestra la sala con su color normal
			else:
				# Si la sala NO ha sido visitada
				
				lock.visible = true 
				# Muestra el candado
				
				room.modulate = Color(0.15, 0.15, 0.15, 1) 
				# Oscurece la sala para indicar que está bloqueada
