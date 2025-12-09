extends Camera2D


func _ready() -> void:
	if owner is Map:
		set_camera_limits(owner.main_tile_map)


func set_camera_limits(tile_map: TileMapLayer):
	var map_rect: Rect2i = tile_map.get_used_rect()
	var tile_size: int  = tile_map.tile_set.tile_size.x
	limit_left = map_rect.position.x * tile_size
	limit_right = map_rect.end.x * tile_size
	limit_top = map_rect.position.y * tile_size
	limit_bottom = map_rect.end.y * tile_size
