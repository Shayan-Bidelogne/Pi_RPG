extends Label


func _physics_process(_delta: float) -> void:
	text = "FPS: " + str(snappedf(Engine.get_frames_per_second(), 2.0)).pad_decimals(0)
