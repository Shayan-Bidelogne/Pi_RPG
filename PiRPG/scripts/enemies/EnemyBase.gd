class_name EnemyBase extends AnimatableBody2D

# |----- Disclaimer -------
# | If it feels like it's missing stuff, that's because I probably
# | deleted commented code that had actual previous codes.
# | But still, this one is the code that is working, so feel free to "figure"
# | stuff that might be clear or not.
# |
# | Also notice the use of variable and functions/methods nomination.
# | It's really important that you have variables that tell exactly what they do,
# | or else you will have problems when you're not working on this code anymore like
# | 3 weeks after "finishing" it. So always try make stuff clear for your own sake
# | for the future debugging.
# | ---------------------

enum states {IDLE, WALK}
var state = states.IDLE

@export var idle_timeout = 4.0
@export var walk_timeout = 1.2

@onready var animation_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var tile_size = Global.TILE_SIZE

# RAYS
@onready var ray_u = $ray_u
@onready var ray_d = $ray_d
@onready var ray_l = $ray_l
@onready var ray_r = $ray_r

var last_direction = Vector2.ZERO
var picked_direction = Vector2.ZERO

func _ready() -> void:
	# Notice that all code that uses new "positioning" is a snap
	# that use tile_size reference. Without it, things will "tile out" and
	# you will have a messy collision/movement really fast.
	# !!! Idk why I had to use tile_size * 2 but it was probably a misalignment
	# !!! from the enemies. Try things out and you will fix/correct stuff.
	global_position = global_position.snappedf(tile_size*2)
	randomize()

func _physics_process(_delta: float) -> void:
	# This variable is the equivalent of player input.
	# Since enemy has only 1 input per frame (he only shifts once)
	# you don't need more complexity than this.
	# But notice it's decision will be stored on a "picked_direction" and
	# "last_direction" for future purposes and not just movement; Animation.
	var direction = Vector2.ZERO
	var rays = [ray_u.is_colliding(), ray_d.is_colliding(),
				ray_l.is_colliding(), ray_r.is_colliding()]
	var rand_pick_idx = -1

	# Basic state machine "shift". Also check Timers time left so it won't be picking
	# a new direction/position every frame he's idle.
	if state == states.IDLE and not $IdleTimer.time_left:
		var movements = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
		rand_pick_idx = randi() % movements.size()
		if rays[rand_pick_idx]:
			while rays[rand_pick_idx]:
				rand_pick_idx = randi() % movements.size()
		picked_direction = movements[rand_pick_idx]
		direction = global_position.snappedf(tile_size) + picked_direction * tile_size

		var tween = create_tween()
		tween.tween_property(
			self, "position", #Who and what to manipulate
			direction, #Where to go
			walk_timeout #Time interval in seconds to get there
		)
		tween.finished.connect(_on_walk_timer_timeout)

		last_direction = direction
		state = states.WALK
		$WalkTimer.start(randf_range(walk_timeout/2, walk_timeout*2))
	elif state == states.WALK:

		var animation_name = get_animation_string(picked_direction)
		if animation_sprite.sprite_frames.has_animation(animation_name):
			animation_sprite.play(animation_name)
	
	# This is a raycast code, this is where the enemy knows where to go (if it has collision)
	# or if he must take another turn because his pick was wrong.
	# If you want, you might test this behaviour by closing it's quarters.
	# Making a 2x2 area to navigate will make the "decision" more aparent, so if you
	# want to study this thing here, just make a wall around 2x2 tiles -- like I did on the
	# map, and you will see it working properly.
	# Also notice the scene tree on the level scene "test". It's "modular" enough so you can
	# Delete all aligators/mobs and have 1 for your debug.
	#var ray_cast = global_position.snappedf(tile_size) + (picked_direction * tile_size/2)
	#$ray.target_position = to_local(ray_cast)
	$coll.global_position = last_direction.snappedf(tile_size)
	#if rand_pick_idx >= 0:
		#if rays..is_colliding()
		#state = states.IDLE
		#direction = global_position
		#return

# Cool function to cut the work of doing it manually. Also notice I'm using it
# just to generate a string. Whatever the way you use it, you must make sure it
# will work. For example, on the original source code, there was an enemy that was having
# problems with animation cause the name of animation didn't existed/was missing
# on it's implementation.
func get_animation_string(direction: Vector2) -> String:
	var string = "idle_"
	if state == states.WALK:
		string = "walk_"

	match direction:
		Vector2.LEFT:
			string += "left"
		Vector2.RIGHT:
			string += "right"
		Vector2.UP:
			string += "up"
		_:
			string += "down"

	return string

# It's a signal connection you make through the editor. You pick a node on your
# scenetree on the left, go to the inspector tab and will find a "Node" button
# right on top. There you might connect signals without having to use _ready
# for that. All the logic down here is based on shifting state, so it "prepares"
# the mob for the next cycle/time he will need to move.
func _on_walk_timer_timeout() -> void:
	state = states.IDLE

	var animation_name = get_animation_string(picked_direction)
	if animation_sprite.sprite_frames.has_animation(animation_name):
		animation_sprite.play(animation_name)

	$IdleTimer.start(randf_range(idle_timeout/2, idle_timeout))
