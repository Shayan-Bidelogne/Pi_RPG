extends Control


func _enter_tree() -> void:
	if not OS.has_feature("debug"):
		queue_free()


func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_key_label_pressed(KEY_U):
		visible = !visible


func _on_hide_debug_button_pressed() -> void:
	hide()
