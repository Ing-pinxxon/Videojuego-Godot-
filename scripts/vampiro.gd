extends Enemy
class_name Vampiro

func _ready():
	max_health = 4
	speed = 130
	detection_range = 300
	show_health_bar = true
	super._ready()

func _setup_detection():
	for node in get_tree().get_nodes_in_group("player"):
		if node is CharacterBody2D:
			target_player = node
			break

func _attack_logic(_delta):
	# Vampiro attacks by jumping through player
	if target_player:
		var moveDirection = target_player.global_position - global_position
		velocity = moveDirection.normalized() * (speed * 1.5)
	else:
		velocity = Vector2.ZERO
