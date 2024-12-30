extends RigidBody2D

# Variables to control movement
var speed: float = 100.0         # Horizontal movement speed
var amplitude: float = 20.0      # Vertical movement amplitude
var frequency: float = 1.0       # Vertical movement frequency
var roaming_distance: float = 200.0  # Horizontal roaming range from the starting position

# Private variables
var direction: int = 1           # 1 for right, -1 for left
var initial_position: Vector2    # Store the initial position for movement bounds

func _ready() -> void:
	initial_position = position  # Record the starting position

func _process(delta: float) -> void:
	# Calculate vertical offset using sine wave
	var time_in_seconds = Time.get_ticks_msec() / 1000.0
	var vertical_offset: float = amplitude * sin(frequency * time_in_seconds)

	# Move horizontally within the roaming distance
	position.x += speed * direction * delta

	# Reverse direction if the enemy reaches the roaming bounds
	if position.x < initial_position.x - roaming_distance or position.x > initial_position.x + roaming_distance:
		direction *= -1

	# Apply vertical floating
	position.y = initial_position.y + vertical_offset
