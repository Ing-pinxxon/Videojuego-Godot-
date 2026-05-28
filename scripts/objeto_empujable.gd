extends CharacterBody2D

func _ready():
	add_to_group("empujable")

func _physics_process(_delta):
	move_and_slide()
	velocity = Vector2.ZERO
