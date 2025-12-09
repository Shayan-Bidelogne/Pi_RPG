extends Area2D

# General variables
@export var projectile_speed: int = 80
@export var lifetime: float = 1.5

var direction := Vector2.ZERO


func _ready() -> void:
	# Delete the fire ball when lasting too long.
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _process(delta: float) -> void:
	position += direction * projectile_speed * delta # Move the projectile in the direction is facing
	if position.x < -100 or position.x > 2000:
		queue_free() # If it gets out of the screen, destroy it.


func _on_area_entered(area: Area2D) -> void:
	# Here we'll manage if the fireball hit and enemy or another object!
	if area:
		queue_free()
