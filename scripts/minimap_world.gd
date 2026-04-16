extends Node2D

@onready var player_icon = $PlayerIcon

var player_real: Node2D

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
					var dist = player_real.global_position.distance_to(child.global_position)
					if dist < min_dist:
						min_dist = dist
						closest_room = child
		
		if closest_room:
			var minimap_room = $Rooms.get_node_or_null(NodePath(closest_room.name))
			if minimap_room:
				var local_pos = player_real.global_position - closest_room.global_position
				player_icon.global_position = minimap_room.global_position + local_pos
			else:
				player_icon.position = player_real.global_position
		else:
			player_icon.position = player_real.global_position
			
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
