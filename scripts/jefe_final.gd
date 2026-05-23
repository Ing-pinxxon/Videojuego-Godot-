extends Enemy

var projectile_scene = preload("res://scenes/entities/enemies/projectile_enemigo.tscn")
var attack_timer = 0.0
var fire_rate = 1.5

func _ready():
	max_health = 25
	speed = 100
	detection_range = 500
	attack_range = 350
	show_health_bar = true
	damage_to_player = 3
	super._ready()

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

func _shoot():
	if target_player:
		var p = projectile_scene.instantiate()
		get_parent().add_child(p)
		p.global_position = global_position
		var dir = (target_player.global_position - global_position).normalized()
		p.direction = dir

func _attack_logic(_delta):
	# Boss moves slowly around player while shooting
	if target_player:
		var dist = global_position.distance_to(target_player.global_position)
		if dist < 200:
			var moveDirection = global_position - target_player.global_position
			velocity = moveDirection.normalized() * speed
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO
