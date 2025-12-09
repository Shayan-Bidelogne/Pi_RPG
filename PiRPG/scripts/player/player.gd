class_name Player extends CharacterBody2D

# |----- Disclaimer -------
# | This is basically a copy+paste from EnemyBase source code.
# | Anything you want to know, try reading EnemyBase since it was the
# | original idea for this code, and then you might understand how and when
# | stuff was added here and the whys it's a bit (if not so) different from the
# | EnemyBase version that is really simplified.
# | ---------------------

enum MOVEMENT_KEYS {LEFT, RIGHT, DOWN, UP}
enum states {IDLE, WALK}
var state = states.IDLE

@export var idle_timeout = 0.2
@export var walk_timeout = 0.2

@onready var animation_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var tile_size = Global.TILE_SIZE

var last_direction = Vector2.ZERO
var picked_direction = Vector2.ZERO
var has_next_move = false

func _ready() -> void:
	global_position = global_position.snappedf(tile_size*2)
	randomize()

func _physics_process(_delta: float) -> void:
	
	# instead of direction, it's "input_vector". Very "ok" code.
	var input_vector = Vector2.ZERO
	
	# I tried remaking the original source code and somewhat it does work ok.
	# It might not be "proper" but it's fine for now and better yet, it's easy 
	# to change if needed later on.
	var keys: Array[bool] = [
		Input.is_action_pressed("ui_left"),
		Input.is_action_pressed("ui_right"),
		Input.is_action_pressed("ui_down"),
		Input.is_action_pressed("ui_up")
	]
	
	# Simple "query" so you pick the first input that was found on the keymap.
	# If up or down were first, they would have "preference". But since horizontal
	# keys were first, those are more than the others. So horizontal movement wins.
	# Also I'm using a "match" case to see which value was pressed.
	# This match is kind of wrong by standards, but I think it works well.
	# The fix for it would be just making a enum so 0, 1, 2, 3 has meaning (for debug sake).
	#
	# !!! I added a enum called "Movement_keys" as I was writing the comments
	# !!! Yet you might understand that it was basically using: 0, 1, 2, 3.
	# !!! This is basically what the enum does but with tags. So instead of having
	# !!! constants with values addressed to tag them, enums are just that.
	# !!! Enum example: 0, 1, 2 -> enum states { IDLE, WALKING, ATTACKING }
	var idx = keys.find(true)
	match idx:
		MOVEMENT_KEYS.LEFT: input_vector = Vector2.LEFT
		MOVEMENT_KEYS.RIGHT: input_vector = Vector2.RIGHT
		MOVEMENT_KEYS.DOWN: input_vector = Vector2.DOWN
		MOVEMENT_KEYS.UP: input_vector = Vector2.UP
	
	# Trying to simplify the explanation, it tries to make a move based on the input.
	# If input is valid (no walls/collision) it will be used on the if down below.
	#
	# Also this if down here just "pick" a valid direction, so instead of moving on the
	# same frame you picked a decision, it stores the value evaluated on last frame and
	# if that was valid, it will run on the next one.
	# Notice the "has_next_move". This is basically a "preview" movement before you actually move.
	#
	# Also it only needed to be this way because of the raycast. It only queries at 1 frame.
	# So, if you have a collision on 1 frame, it will never know... But if you try a move, store
	# and on the next check for a collision, then you will filter and avoid further bugs.
	var probable_movement = global_position.snappedf(tile_size) + (input_vector * tile_size)
	if input_vector != Vector2.ZERO and not has_next_move:
		var ray_cast = global_position.snappedf(tile_size) + (input_vector * tile_size/2)
		$ray.target_position = to_local(ray_cast)
		$coll.global_position = ray_cast
		$ray.position = to_local(ray_cast)
		has_next_move = true
		return
	
	if $ray.is_colliding():
		state = states.IDLE
		has_next_move = false
		return
	
	# Same stuff form the enemyBase, but with a few wrongdoings as I was trying to figure
	# how to adapt the same code for the player. Notice this one isn't meant to be modular,
	# it was really trying to solve the "grid" problem I noticed before.
	# So this is just a copy+paste to avoid rework on something I already did.
	# But also keep in mind that most of the player code is just for movement, as well as
	# the mob, player only needs a code for movement and all combat can be handled by a
	# combatComponent. It avoids mixing combat, stats and movement on the same source.
	# So it's easier to debug code, reimplement and on this case, prototype stuff.
	# Example: You think of one system in 1 way, someone else in a secondary way and so on...
	# When it has to be implemented, it shouldn "break" the whole code. All you need is to connect
	# the dots where movement is needed and where "combat" component or "ui" is asking for a player.
	#
	# This mean we need to avoid at all cost "copling" code and even more making it
	# more complex than it should. Make stuff simple and try connect the dots. That's what we need here.
	if state == states.IDLE and input_vector.length() > 0.3 and not $IdleTimer.time_left and has_next_move:
		
		picked_direction = input_vector
		
		var tween = create_tween()
		tween.tween_property(
			self, "position", #Who and what to manipulate
			probable_movement, #Where to go
			walk_timeout #Time interval in seconds to get there
		)
		#tween.finished.connect(_on_walk_timer_timeout)

		state = states.WALK
		$WalkTimer.start(walk_timeout/2)
		has_next_move = false
	elif state == states.WALK:
		var animation_name = get_animation_string(picked_direction)
		if animation_sprite.sprite_frames.has_animation(animation_name):
			animation_sprite.play(animation_name)
	else:
		state = states.IDLE
		has_next_move = false

# Same code. I actually think I'll make a "tool class" just for these kind of codes.
# It's reusable and it's been repeated.
# But since this code is literally a copy+paste from the enemyBase, I didn't bothered.
# It's for the sake of reimplementing movement, this thing is just a tool really.
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

# Same stuff from the enemy/mob code.
func _on_walk_timer_timeout() -> void:
	state = states.IDLE
	has_next_move = false

	$IdleTimer.start(idle_timeout/2)

# This was just a work around to make animation cycle. It's bugging but it works for now.
func _on_animated_sprite_2d_animation_looped() -> void:
	var animation_name = get_animation_string(picked_direction)
	if animation_sprite.sprite_frames.has_animation(animation_name):
		animation_sprite.play(animation_name)
