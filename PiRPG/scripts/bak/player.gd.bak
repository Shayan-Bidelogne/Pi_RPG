class_name Player
extends CharacterBody2D

# Load other scenes (Projectiles at the moment)
var fireball_scene = preload("res://src/system/combat/projectile/fireball.tscn")

# Movements
@export var move_duration: float = 0.2

var is_moving: float = false
var input_stack: Array[String] = []
var input_vector: Vector2
var last_input_vector: Vector2

# Gameplay
var stats: Dictionary = {
	"health": 10.0,
}
var progression: Dictionary = {
	"level": 0,
	"experience": 0.0,
	"experience_required": 50.0
}
var team: int

@onready var animation_player: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	# Default animation
	play_anim("idle_", Vector2.DOWN)
	# Snap base position to grid.
	position = position.snappedf(Global.TILE_SIZE)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		shoot_projectile()

func _physics_process(_delta: float) -> void:
	if is_moving:
		return
	
	input_vector = Vector2.ZERO

	# Update stack based on pressed inputs
	update_input_stack()

	# Use the last input in the stack if available
	if input_stack.size():
		match input_stack[-1]: # Last item
			"up": input_vector = Vector2.UP
			"down": input_vector = Vector2.DOWN
			"left": input_vector = Vector2.LEFT
			"right": input_vector = Vector2.RIGHT

	if input_vector:
		last_input_vector = input_vector
		try_move(input_vector)
	else:
		play_anim("idle_", last_input_vector)


func update_input_stack():
	var directions = {
		"up": Input.is_action_pressed("ui_up"),
		"down": Input.is_action_pressed("ui_down"),
		"left": Input.is_action_pressed("ui_left"),
		"right": Input.is_action_pressed("ui_right")
	}

	# Remove any keys no longer pressed
	for key in input_stack.duplicate():
		if !directions.get(key, false):
			input_stack.erase(key)

	# Add newly pressed keys
	for key in directions.keys():
		if directions[key] and not input_stack.has(key):
			input_stack.append(key)

func try_move(direction: Vector2) -> void:
	var target: Vector2 = global_position + direction * Global.TILE_SIZE
	
	# Debug purpose
	$Icon.global_position = target
	
	# Before we were using intersect_ray, don't hesitate to use it back if needed
	#PhysicsPointQueryParameters2D.create(global_position, target, collision_mask, [self])
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	query.position = target

	var result: Array[Dictionary] = space_state.intersect_point(query)
	if result.is_empty():
		start_movement(global_position + direction * Global.TILE_SIZE)
	else:
		play_anim("idle_", direction)


func start_movement(target_position: Vector2) -> void:
	is_moving = true
	play_anim("walk_", last_input_vector)
	
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", target_position, move_duration)
	tween.finished.connect(on_move_finished)

func on_move_finished() -> void:
	is_moving = false

# Handle player's animations
func play_anim(state: String, direction: Vector2) -> void:
	var direction_name: String = "down"
	if direction == Vector2.LEFT:
		direction_name = "left"
	elif direction == Vector2.RIGHT:
		direction_name = "right"
	elif direction == Vector2.UP:
		direction_name = "up"
	elif direction == Vector2.DOWN:
		direction_name = "down"
	animation_player.play(state + direction_name)

func shoot_projectile():
	if last_input_vector == Vector2.ZERO: # If the player does not have direction, doesn't shoot
		return 
	
	# Instantiate the fireball
	var fireball = fireball_scene.instantiate()
	fireball.global_position = global_position + last_input_vector.normalized() # Adjusts the fireball position
	# Set direction of the fireball
	fireball.direction = last_input_vector
	fireball.rotation = last_input_vector.angle()
	get_tree().current_scene.add_child(fireball)
