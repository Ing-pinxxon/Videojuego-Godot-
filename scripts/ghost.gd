extends Enemy

# Ghost is a melee enemy that chases the player
func _ready():
	super._ready()
	# Ghost specific setup
	speed = 120
	detection_range = 250.0
	attack_range = 40.0
	max_health = 3
	health = max_health

func _setup_detection():
	for node in get_tree().get_nodes_in_group("player"):
		if node is CharacterBody2D:
			target_player = node
			break

func _attack_logic(_delta):
	# Ghost is persistent, even in attack range it stays on top of player
	if target_player:
		var moveDirection = target_player.global_position - global_position
		velocity = moveDirection.normalized() * (speed * 0.8)
	else:
		velocity = Vector2.ZERO
