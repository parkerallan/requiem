extends CharacterBody2D

signal hit
@export var MOVE_SPEED = 400
@export var GRAVITY = 800
@export var JUMP_FORCE = 500
var is_crouching = false
var is_attacking = false

func _ready() -> void:
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.flip_h = true

# Called every frame
func _process(delta: float) -> void:
	# Reset horizontal velocity
	velocity.x = 0

	# Handle attack
	if Input.is_action_just_pressed("attack"):
		_attack()

	# Handle crouch
	if Input.is_action_pressed("duck"):
		is_crouching = true
	else:
		is_crouching = false

	# Skip movement if attacking or crouching
	if not is_attacking and not is_crouching:
		# Horizontal movement
		if Input.is_action_pressed("move_right"):
			velocity.x += MOVE_SPEED
		if Input.is_action_pressed("move_left"):
			velocity.x -= MOVE_SPEED
		
		# Jumping
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = -JUMP_FORCE
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Update animations
	_update_animations()

	# Move the character
	move_and_slide()

# Animation update function
func _update_animations() -> void:
	if is_attacking:
		$AnimatedSprite2D.animation = "attack"
	elif is_crouching:
		$AnimatedSprite2D.animation = "duck"
	elif not is_on_floor():
		$AnimatedSprite2D.animation = "jump"
	elif velocity.x != 0:
		$AnimatedSprite2D.animation = "run"
	else:
		$AnimatedSprite2D.animation = "idle"

	# Flip sprite based on movement direction
	if velocity.x != 0:
		$AnimatedSprite2D.flip_h = velocity.x > 0
	
	$AnimatedSprite2D.play()

# Attack function
func _attack() -> void:
	is_attacking = true
	$AnimatedSprite2D.animation = "attack"
	$AnimatedSprite2D.play()

	# Use a timer to reset attack state after animation finishes
	var attack_timer = Timer.new()
	attack_timer.one_shot = true
	attack_timer.wait_time = 0.25  # Adjust this to match the attack animation duration
	add_child(attack_timer)
	attack_timer.connect("timeout", Callable(self, "_on_attack_finished"))
	attack_timer.start()

# Reset attack state
func _on_attack_finished() -> void:
	is_attacking = false

func _on_body_entered(body: Node2D) -> void:
	hide() # Player disappears after being hit.
	hit.emit()
	# We need to disable the player's collision so that we don't trigger the hit signal more than once.
	$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
