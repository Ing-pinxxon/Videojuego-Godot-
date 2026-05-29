extends Enemy
class_name Demonio

@export var projectile_scene: PackedScene = preload("res://scenes/entities/enemies/projectile_enemigo.tscn")
var attack_timer: float = 0.0
@export var fire_rate: float = 3.0
var hit_stun_timer: float = 0.0
const HIT_STUN_DURATION: float = 0.4

func _ready():
	speed = 80
	detection_range = 400.0
	attack_range = 300.0
	max_health = 5
	show_health_bar = false
	attack_timer = fire_rate - 0.5
	super._ready()

	if hearts_container:
		hearts_container.alignment = BoxContainer.ALIGNMENT_CENTER

func _physics_process(_delta):
	# Cuenta regresiva del hit stun
	if hit_stun_timer > 0:
		hit_stun_timer -= _delta
		velocity = Vector2.ZERO
		move_and_slide()
		return

	super._physics_process(_delta)
	if current_state == State.ATTACK or current_state == State.CHASE:
		attack_timer += _delta
		if attack_timer >= fire_rate:
			_shoot()
			attack_timer = 0.0

func take_damage(amount: int):
	super.take_damage(amount)
	# Al recibir daño se queda quieto brevemente
	hit_stun_timer = HIT_STUN_DURATION

func _attack_logic(_delta):
	if target_player:
		var dist = global_position.distance_to(target_player.global_position)
		if dist < 150:
			var moveDirection = global_position - target_player.global_position
			velocity = moveDirection.normalized() * speed
		elif dist > 250:
			var moveDirection = target_player.global_position - global_position
			velocity = moveDirection.normalized() * (speed * 0.5)
		else:
			velocity = Vector2.ZERO

func _chase_logic(_delta):
	if target_player:
		var dist = global_position.distance_to(target_player.global_position)
		if dist < 200:
			var moveDirection = global_position - target_player.global_position
			velocity = moveDirection.normalized() * speed
		else:
			super._chase_logic(_delta)

func _shoot():
	if is_dead or not target_player: return

	# Disparar desde el pecho/boca del demonio (15 píxeles arriba de su origen)
	var shoot_pos = global_position - Vector2(0, 15)
	# Apuntar al pecho del jugador (16px arriba de su origen) para que el proyectil viaje recto
	var player_center = target_player.global_position - Vector2(0, 16)
	var base_dir = (player_center - shoot_pos).normalized()
	var angles = [-0.35, 0.0, 0.35]

	for angle in angles:
		var projectile = projectile_scene.instantiate()
		# Asignar base_scale ANTES de agregarlo a la escena para que _ready() aplique la colisión correcta
		if "base_scale" in projectile:
			projectile.base_scale = 1.8 # Bolas de fuego gigantes
			projectile.speed = 220.0 # Velocidad más pesada y realista para proyectiles grandes
		projectile.direction = base_dir.rotated(angle)
		projectile.modulate = Color(1.0, 0.45, 0.0) # Rojo-naranja ígneo vibrante
		get_parent().add_child(projectile)
		# En Godot 4, se debe asignar global_position DESPUÉS de add_child para evitar desfases del padre
		projectile.global_position = shoot_pos

	if animations.sprite_frames.has_animation("attack"):
		animations.play("attack")
