extends Enemy

# Esqueleto is a fast melee enemy
func _ready():
	super._ready()
	speed = 150
	max_health = 2
	health = max_health
	detection_range = 300.0

func _setup_detection():
	for node in get_tree().get_nodes_in_group("player"):
		if node is CharacterBody2D:
			target_player = node
			break

func _attack_logic(_delta):
	# Esqueleto attacks with quick bursts
	if target_player:
		var moveDirection = target_player.global_position - global_position
		velocity = moveDirection.normalized() * speed
	else:
		velocity = Vector2.ZERO
