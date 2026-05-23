extends Enemy

# Zombie is a slow but tanky enemy
func _ready():
	speed = 50
	max_health = 5
	show_health_bar = true
	super._ready()
	health = max_health
	damage_to_player = 2
	detection_range = 150.0

func _setup_detection():
	for node in get_tree().get_nodes_in_group("player"):
		if node is CharacterBody2D:
			target_player = node
			break

func _attack_logic(_delta):
	# Zombi is slow but doesn't stop, it keeps pushing towards player
	if target_player:
		var moveDirection = target_player.global_position - global_position
		velocity = moveDirection.normalized() * (speed * 0.4)
	else:
		velocity = Vector2.ZERO
