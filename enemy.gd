extends CharacterBody2D

@export var move_speed = 10000

var facing_right = true
var player: PhysicsBody2D = null

func _ready():
	$AnimatedSprite2D.animation = "move"
	$AnimatedSprite2D.flip_v = false
	$AnimatedSprite2D.play()

func _physics_process(delta):
	var direction = Vector2.ZERO

	if player:
		direction = player.position - position
		direction = direction.normalized()
		facing_right = direction.x < 0
	
	velocity = direction * delta * move_speed
	move_and_slide()
	
	$AnimatedSprite2D.flip_h = facing_right


func _on_area_2d_body_entered(body):
	if body.collision_layer == 1:
		player = body
