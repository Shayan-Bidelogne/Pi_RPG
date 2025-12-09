class_name Projectile
extends Area2D


@export var startup_animation: StringName = &""
@export var default_animation: StringName = &"orange_fire_ball"
@export var impact_animation: StringName = &"orange_fire_ball_impact"
@export var destroy_animation: StringName = &"orange_fire_ball_impact"

var source: Node
var attack: Attack

var speed: float = 130.0
var piercing: bool = false

var direction: Vector2 = Vector2.RIGHT:
	set = _set_direction

var fired: bool = false
var default_rotation: float = PI / 2

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	animated_sprite.play()
	if startup_animation:
		animated_sprite.play(startup_animation)
		await animated_sprite.animation_finished
	animated_sprite.play(default_animation)
	fired = true


func _physics_process(delta: float) -> void:
	if fired:
		position += direction * speed * delta


func _set_direction(new_direction: Vector2) -> void:
	direction = new_direction
	rotate(direction.angle() + default_rotation)


func _on_body_entered(body: Node2D) -> void:
	if body != source and body.has_method("receive_attack"):
		body.receive_attack(attack)
	if not piercing:
		fired = false
		monitoring = false
		if destroy_animation:
			animated_sprite.play(destroy_animation)
			await animated_sprite.animation_finished
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
