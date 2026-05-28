extends Enemy
class_name Bestia

func _ready():
	max_health = 10
	speed = 70
	detection_range = 250
	show_health_bar = true
	super._ready()

func _setup_detection():
	for node in get_tree().get_nodes_in_group("player"):
		if node is CharacterBody2D:
			target_player = node
			break

func _attack_logic(_delta):
	# Bestia is slow but hits hard
	if target_player:
		var moveDirection = target_player.global_position - global_position
		velocity = moveDirection.normalized() * (speed * 0.5)
	else:
		velocity = Vector2.ZERO
