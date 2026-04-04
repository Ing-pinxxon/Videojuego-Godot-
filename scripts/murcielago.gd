extends CharacterBody2D

@export var speed = 100
@export var direction = Vector2(1, 0)
@export var limit_x = 200
@export var limit_y = 50

@export var detection_radius = 200.0   # Radio para detectar al player
@export var attack_radius = 40.0       # Radio para atacar
@export var chase_speed = 150.0        # Velocidad al perseguir

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var start_position: Vector2
var player: Node2D = null

enum State { PATROL, CHASE, ATTACK }
var current_state: State = State.PATROL

func _ready():
	start_position = global_position
	# Busca al player automáticamente (debe estar en el grupo "player")
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	match current_state:
		State.PATROL:
			_do_patrol(delta)
		State.CHASE:
			_do_chase(delta)
		State.ATTACK:
			_do_attack(delta)

	_update_state()
	move_and_slide()

func _update_state():
	if player == null:
		return

	var dist = global_position.distance_to(player.global_position)

	match current_state:
		State.PATROL:
			if dist <= detection_radius:
				current_state = State.CHASE

		State.CHASE:
			if dist <= attack_radius:
				current_state = State.ATTACK
			elif dist > detection_radius:
				current_state = State.PATROL

		State.ATTACK:
			if dist > attack_radius:
				current_state = State.CHASE

func _do_patrol(delta: float):
	velocity.x = speed * direction.x
	velocity.y = speed * direction.y

	if abs(global_position.x - start_position.x) >= limit_x:
		direction.x *= -1
	if abs(global_position.y - start_position.y) >= limit_y:
		direction.y *= -1

	sprite.flip_h = velocity.x < 0

	if not sprite.is_playing():
		sprite.play("movimiento")

func _do_chase(delta: float):
	if player == null:
		return

	var dir = (player.global_position - global_position).normalized()
	velocity = dir * chase_speed
	sprite.flip_h = velocity.x < 0

	if sprite.animation != "movimiento":
		sprite.play("movimiento")

func _do_attack(_delta: float):
	velocity = Vector2.ZERO

	# Lanza el ataque una sola vez al entrar al estado
	if sprite.animation != "ataque":
		sprite.play("ataque")
		# Aquí llamas el daño al player, por ejemplo:
		# player.take_damage(10)
