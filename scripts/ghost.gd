extends Enemy
class_name Ghost

var hit_stun_timer: float = 0.0
const HIT_STUN_DURATION: float = 0.4

func _ready():
	speed = 120
	detection_range = 250.0
	attack_range = 40.0
	max_health = 3
	super._ready()

func _physics_process(_delta):
	if hit_stun_timer > 0:
		hit_stun_timer -= _delta
		velocity = Vector2.ZERO
		move_and_slide()
		return
	super._physics_process(_delta)

func take_damage(amount: int):
	super.take_damage(amount)
	hit_stun_timer = HIT_STUN_DURATION

func _attack_logic(_delta):
	if target_player:
		var moveDirection = target_player.global_position - global_position
		velocity = moveDirection.normalized() * (speed * 0.8)
	else:
		velocity = Vector2.ZERO
