extends Enemy
class_name Esqueleto

func _ready():
	super._ready()
	speed = 150
	max_health = 2
	health = max_health
	detection_range = 300.0
	_update_hearts()

func _attack_logic(_delta):
	if target_player:
		var moveDirection = target_player.global_position - global_position
		velocity = moveDirection.normalized() * speed
	else:
		velocity = Vector2.ZERO
