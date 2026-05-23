extends Enemy

@export var projectile_scene: PackedScene = preload("res://scenes/entities/enemies/projectile_enemigo.tscn")
var attack_timer: float = 0.0
@export var fire_rate: float = 2.0

func _ready():
	speed = 80
	detection_range = 400.0
	attack_range = 300.0
	max_health = 2
	show_health_bar = false  # Usa corazones, no barra
	
	super._ready()  # Esto ya crea y configura hearts_container
	
	# Solo personaliza la posición si es necesario
	if hearts_container:
		hearts_container.alignment = BoxContainer.ALIGNMENT_CENTER
		# Posición relativa al sprite (se ajustará automáticamente)
		# Si quieres posición absoluta en pantalla, usa CanvasLayer
	
	

func _setup_detection():
	for node in get_tree().get_nodes_in_group("player"):
		if node is CharacterBody2D:
			target_player = node
			break

func _physics_process(_delta):
	super._physics_process(_delta)
	if current_state == State.ATTACK or current_state == State.CHASE:
		attack_timer += _delta
		if attack_timer >= fire_rate:
			_shoot()
			attack_timer = 0.0

func _attack_logic(_delta):
	# Even when attacking, maintain distance if player gets too close
	if target_player:
		var dist = global_position.distance_to(target_player.global_position)
		if dist < 150: # If too close, back away
			var moveDirection = global_position - target_player.global_position
			velocity = moveDirection.normalized() * speed
		elif dist > 250: # If too far, approach slightly
			var moveDirection = target_player.global_position - global_position
			velocity = moveDirection.normalized() * (speed * 0.5)
		else:
			velocity = Vector2.ZERO

func _chase_logic(_delta):
	if target_player:
		var dist = global_position.distance_to(target_player.global_position)
		# Maintain distance
		if dist < 200:
			var moveDirection = global_position - target_player.global_position
			velocity = moveDirection.normalized() * speed
		else:
			super._chase_logic(_delta)

func _shoot():
	if is_dead or not target_player: return
	
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	projectile.direction = (target_player.global_position - global_position).normalized()
	get_parent().add_child(projectile)
	
	if animations.sprite_frames.has_animation("attack"):
		animations.play("attack")
