extends Label


func _ready() -> void:
	text = "V-Sync: " + "Activated" if DisplayServer.window_get_vsync_mode() else "Desactivated"
