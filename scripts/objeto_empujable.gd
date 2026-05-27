extends CharacterBody2D

const VELOCIDAD := 60.0

func _physics_process(_delta):
	velocity = Vector2.ZERO
	move_and_slide()
