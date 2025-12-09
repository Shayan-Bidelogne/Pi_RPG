class_name Mob
extends CharacterBody2D

@export var move_duration: float = 0.2
@export var move_interval: float = 1.2
@export var shoot_interval: float = 2.0
@export var orbit_distance: int = 3
@export var detection_range: float = 64

var is_moving: bool = false
var last_input_vector: Vector2 = Vector2.DOWN
var target_timer: float = 0.0
var shoot_timer: float = 0.0

var stats := {
	"health": 5.0
}

var fireball_scene = preload("res://scripts/combat/projectile/fireball.tscn")

@onready var animation_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: Node2D = null

# Anti-clockwise directions for orbiting around player
var orbit_directions := [Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN]
var current_orbit_index: int = 0

func _ready() -> void:
	play_anim("idle_", Vector2.DOWN)
	position = position.snappedf(Global.TILE_SIZE)

	target_timer = move_interval * (0.5 + randf())
	shoot_timer = shoot_interval * (0.5 + randf())

	player = get_tree().current_scene.find_child("Player")


func _physics_process(delta: float) -> void:
	if is_moving:
		return

	# -----------------------------
	# Movement timer
	# -----------------------------
	target_timer -= delta
	if target_timer <= 0:
		target_timer = move_interval
		if player:
			move_logic()
		else:
			play_anim("idle_", last_input_vector)

	# -----------------------------
	# Shooting timer
	# -----------------------------
	if player and (player.global_position - global_position).length() <= detection_range:
		shoot_timer -= delta
		if shoot_timer <= 0:
			shoot_fireball()
			shoot_timer = shoot_interval


# -----------------------------
# Movement logic: approach player then orbit anti-clockwise
# -----------------------------
func move_logic() -> void:
	var diff = player.global_position - global_position
	var dist_tiles = round(diff.length() / Global.TILE_SIZE)

	if dist_tiles > orbit_distance:
		# Move toward player
		if abs(diff.x) > abs(diff.y):
			last_input_vector = Vector2.RIGHT if diff.x > 0 else Vector2.LEFT
		else:
			last_input_vector = Vector2.DOWN if diff.y > 0 else Vector2.UP
	else:
		# Orbit anti-clockwise around player
		current_orbit_index = (current_orbit_index + 1) % orbit_directions.size()
		last_input_vector = orbit_directions[current_orbit_index]

	try_move(last_input_vector)


func try_move(direction: Vector2) -> void:
	var target := global_position + direction * Global.TILE_SIZE

	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = target
	var result = space_state.intersect_point(query)

	if result.is_empty():   # <-- correction ici
		start_movement(target)
	else:
		play_anim("idle_", direction)


func start_movement(target_position: Vector2) -> void:
	is_moving = true
	play_anim("walk_", last_input_vector)

	var tween = create_tween()
	tween.tween_property(self, "position", target_position, move_duration)
	tween.finished.connect(on_move_finished)


func on_move_finished() -> void:
	is_moving = false


func play_anim(state: String, direction: Vector2) -> void:
	var direction_name := "down"
	if direction == Vector2.LEFT:
		direction_name = "left"
	elif direction == Vector2.RIGHT:
		direction_name = "right"
	elif direction == Vector2.UP:
		direction_name = "up"

	# Clause Guard design pattern used, it's not perfect but it fixes stuff.
	if animation_player.sprite_frames.has_animation(state + direction_name):
		animation_player.play(state + direction_name)


func shoot_fireball() -> void:
	if last_input_vector == Vector2.ZERO:
		return

	var fireball = fireball_scene.instantiate()
	fireball.global_position = global_position + last_input_vector.normalized()
	fireball.direction = last_input_vector
	fireball.rotation = last_input_vector.angle()
	get_tree().current_scene.add_child(fireball)
