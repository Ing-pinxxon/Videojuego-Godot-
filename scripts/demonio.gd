extends Enemy

# Demonio is a high damage, high health, slow enemy
func _ready():
	super._ready()
	speed = 60
	max_health = 8
	health = max_health
	damage_to_player = 3
	detection_range = 200.0

func _setup_detection():
	for node in get_tree().get_nodes_in_group("player"):
		if node is CharacterBody2D:
			target_player = node
			break

func _attack_logic(_delta):
	# Demonio lunges slightly at player when in attack range
	if target_player:
		var moveDirection = target_player.global_position - global_position
		velocity = moveDirection.normalized() * (speed * 1.2)
		# Visual feedback: scale up slightly
		animations.scale = Vector2(1.6, 1.6)
	else:
		velocity = Vector2.ZERO

func _update_animation():
	super._update_animation()
	if current_state != State.ATTACK:
		animations.scale = Vector2(1.44, 1.41) # Reset to original scale
