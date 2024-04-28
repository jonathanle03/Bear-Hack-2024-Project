extends CharacterBody2D

@export var move_speed = 25000
@export var attack_speed = 0.5
@export var attack_cd = 1
@export var invincibility_time = 0.5

var facing_right: bool = true
var prev_right: bool = true
var prev_invincibility: float = 0

func _ready():
	$AnimatedSprite2D.play()
	$Weapon/Area2D/CollisionShape2D.set_deferred("disabled", true)

func _physics_process(delta):
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	
	velocity = direction * delta * move_speed
	move_and_slide()
	
	if not direction:
		$AnimatedSprite2D.animation = "idle"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = facing_right
	else:
		$AnimatedSprite2D.animation = "run"
		$AnimatedSprite2D.flip_v = false
		facing_right = velocity.x < 0
		$AnimatedSprite2D.flip_h = facing_right
	
	if facing_right:
		$Weapon/Area2D.position = Vector2(-12, 14)
		if not prev_right:
			$Weapon/Area2D.rotation_degrees *= -1;
	else:
		$Weapon/Area2D.position = Vector2(12, 14)
		if prev_right:
			$Weapon/Area2D.rotation_degrees *= -1;
	
	if Input.is_action_pressed("attack"):
		if not $AttackCooldownTimer.time_left:
			$AttackTimer.wait_time = attack_speed
			$AttackCooldownTimer.wait_time = attack_cd
			$AttackTimer.start()
			$AttackCooldownTimer.start()

	if $AttackTimer.time_left >= $AttackTimer.wait_time * 0.8:
		if facing_right:
			$Weapon/Area2D.rotation_degrees += delta / (attack_speed * 0.2) * 30
		else:
			$Weapon/Area2D.rotation_degrees -= delta / (attack_speed * 0.2) * 30
	elif $AttackTimer.time_left:
		$Weapon/Area2D/CollisionShape2D.disabled = false
		if facing_right:
			$Weapon/Area2D.rotation_degrees -= delta / (attack_speed * 0.8) * 170
		else:
			$Weapon/Area2D.rotation_degrees += delta / (attack_speed * 0.8) * 170
	elif $AttackCooldownTimer.time_left:
		$Weapon/Area2D/CollisionShape2D.disabled = true
		if facing_right:
			$Weapon/Area2D.rotation_degrees += delta / (attack_cd - attack_speed) * 140
		else:
			$Weapon/Area2D.rotation_degrees -= delta / (attack_cd - attack_speed) * 140

	if $InvincibilityTimer.time_left > 0 and abs($InvincibilityTimer.time_left / 0.125) < prev_invincibility:
		if $AnimatedSprite2D.self_modulate == Color(1, 1, 1, 1):
			$AnimatedSprite2D.set_deferred("self_modulate", Color(1, 1, 1, 0.4))
		else:
			$AnimatedSprite2D.set_deferred("self_modulate", Color(1, 1, 1, 1))

	prev_right = facing_right
	prev_invincibility = abs($InvincibilityTimer.time_left / 0.125)


func _on_area_2d_body_entered(_body):
	if not $InvincibilityTimer.time_left:
		$InvincibilityTimer.wait_time = invincibility_time
		$InvincibilityTimer.start()
		$CollisionShape2D.set_deferred("disabled", true)
		$EnemyCollision/CollisionShape2D.set_deferred("disabled", true)


func _on_invincibility_timer_timeout():
	$CollisionShape2D.set_deferred("disabled", false)
	$EnemyCollision/CollisionShape2D.set_deferred("disabled", false)
	$AnimatedSprite2D.set_deferred("self_modulate", Color(1, 1, 1, 1))
