extends Camera2D

# Exports a field on the editor so level design is easier
@export_node_path("Map") var map_ref

# The actual implementation for references set on editor
# !!! If the item wasn't added on editor, it might crash.
# !!!
# !!! Use guard clause design pattern with if-else
# !!! or it will break the game later on.
@onready var map_instance = get_node(map_ref)

func _ready() -> void:
	# This code is a simple guard clause, but it's not really the proper use.
	if map_instance is Map:
		set_camera_limits(map_instance.main_tile_map)

func set_camera_limits(tile_map: TileMapLayer):
	var map_rect: Rect2i = tile_map.get_used_rect()
	var map_pos = map_rect.position
	var map_end = map_rect.end
	var tile_size: int  = tile_map.tile_set.tile_size.x
	limit_left = map_pos.x * tile_size
	limit_right = map_end.x * tile_size
	limit_top = map_pos.y * tile_size
	limit_bottom = map_end.y * tile_size
	offset = Vector2.ONE * (tile_size/2)
