extends CharacterBody2D

@export var move_duration: float = 0.2           # Duration of movement tween
@export var move_interval: float = 1.2           # Time between moves
@export var shoot_interval: float = 2.0          # Time between shots
@export var detection_range: float = 64          # Range to chase/shoot the player

var is_moving: bool = false
var last_input_vector: Vector2 = Vector2.DOWN
var target_timer: float = 0.0
var shoot_timer: float = 0.0

# Stats
var stats := {
	"health": 5.0
}

# Fireball scene
var fireball_scene = preload("res://scripts/combat/projectile/fireball.tscn")

@onready var animation_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: Node2D = null   # Assigned in _ready()


func _ready() -> void:
	play_anim("idle_", Vector2.DOWN)
	position = position.snappedf(Global.TILE_SIZE)

	# Add a small random offset so different mobs don't move/shoot simultaneously
	target_timer = move_interval * (0.5 + randf())  # random between 0.5x and 1.5x
	shoot_timer = shoot_interval * (0.5 + randf())

	# Find the player node (adjust path if necessary)
	player = get_tree().current_scene.find_child("Player")



func _physics_process(delta: float) -> void:
	if is_moving:
		return

	# -----------------------------
	# Movement logic
	# -----------------------------
	target_timer -= delta
	if target_timer > 0:
		play_anim("idle_", last_input_vector)
	else:
		target_timer = move_interval
		# Determine movement direction: chase if close, else random
		var direction = get_movement_direction()
		last_input_vector = direction
		try_move(direction)

	# -----------------------------
	# Shooting logic
	# -----------------------------
	if player and (player.global_position - global_position).length() <= detection_range:
		shoot_timer -= delta
		if shoot_timer <= 0:
			shoot_fireball()
			shoot_timer = shoot_interval


# -----------------------------
# Determine movement direction
# -----------------------------
func get_movement_direction() -> Vector2:
	var dir_vector = player.global_position - global_position
	if dir_vector.length() <= detection_range:
		# Player is close: move towards player
		var abs_x = abs(dir_vector.x)
		var abs_y = abs(dir_vector.y)
		if abs_x > abs_y:
			return Vector2.RIGHT if dir_vector.x > 0 else Vector2.LEFT
		else:
			return Vector2.DOWN if dir_vector.y > 0 else Vector2.UP
	else:
		# Player is far: move randomly
		var dirs = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
		return dirs[randi() % dirs.size()]


func try_move(direction: Vector2) -> void:
	var target := global_position + direction * Global.TILE_SIZE

	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	query.position = target

	var result: Array = space_state.intersect_point(query)

	if result.is_empty():
		start_movement(target)
	else:
		play_anim("idle_", direction)


func start_movement(target_position: Vector2) -> void:
	is_moving = true
	play_anim("walk_", last_input_vector)

	var tween := create_tween()
	tween.tween_property(self, "position", target_position, move_duration)
	tween.finished.connect(on_move_finished)


func on_move_finished() -> void:
	is_moving = false


# -----------------------------
# Play animations based on direction
# -----------------------------
func play_anim(state: String, direction: Vector2) -> void:
	var direction_name := "down"
	if direction == Vector2.LEFT:
		direction_name = "left"
	elif direction == Vector2.RIGHT:
		direction_name = "right"
	elif direction == Vector2.UP:
		direction_name = "up"

	animation_player.play(state + direction_name)


# -----------------------------
# Shoot a fireball in the movement direction
# -----------------------------
func shoot_fireball() -> void:
	# Only shoot if the mob has a valid movement direction
	if last_input_vector == Vector2.ZERO:
		return

	# Instantiate fireball
	var fireball = fireball_scene.instantiate()
	fireball.global_position = global_position + last_input_vector.normalized()
	fireball.direction = last_input_vector
	fireball.rotation = last_input_vector.angle()
	get_tree().current_scene.add_child(fireball)
