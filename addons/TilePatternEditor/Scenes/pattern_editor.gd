@tool
extends Control


@onready var hover_layer: TileMapLayer = %HoverLayer
@onready var tile_map_layer: TileMapLayer = %TileMapLayer
@onready var highlight_map_layer: TileMapLayer = %HighlightMapLayer

@onready var save_dialog: FileDialog = $SaveDialog
@onready var load_dialog: FileDialog = $LoadDialog
@onready var zoom_control: Control = %ZoomControl


var last_cell_pos := Vector2i.ZERO

var current_map_size := 3

var pattern_resource: TilePatternResource

var is_drawing := false
var is_erasing := false


# Zoom variables
var zoom_level: float = 1.0

const ZOOM_SPEED: float = 0.1
const MIN_ZOOM: float = 0.1
const MAX_ZOOM: float = 4.0

var pan_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	pattern_resource = TilePatternResource.new()
	set_tile_map_size(current_map_size)


func _process(_delta: float) -> void:
	hover_layer.erase_cell(last_cell_pos)

	var cell_pos := hover_layer.local_to_map(hover_layer.get_local_mouse_position())

	if is_cell_in_bounds(cell_pos, current_map_size):
		hover_layer.set_cell(cell_pos, 0, Vector2i(2, 0), 0)

	last_cell_pos = cell_pos


func _input(event: InputEvent) -> void:
	if not visible:
		return

    # zoom and panning
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()

	if (event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_MIDDLE):
		pan_offset += event.relative
		update_view()

	if event is InputEventMouseButton:

        # placing cell
		if event.button_index == MOUSE_BUTTON_LEFT:
			var cell_pos := get_cell_pos_from_mouse()

			if event.pressed and is_cell_in_bounds(cell_pos, current_map_size):
				is_drawing = true
				place_cell(cell_pos)
			else:
				is_drawing = false

        # earasing cell
		if event.button_index == MOUSE_BUTTON_RIGHT:
			var cell_pos := get_cell_pos_from_mouse()

			if event.pressed and is_cell_in_bounds(cell_pos, current_map_size):
				is_erasing = true
				erase_cell(cell_pos)
			else:
				is_erasing = false

	if event is InputEventMouseMotion:
		if is_drawing:
			place_cell(get_cell_pos_from_mouse())

		if is_erasing and not is_drawing:
			erase_cell(get_cell_pos_from_mouse())


func get_cell_pos_from_mouse() -> Vector2i:
	return tile_map_layer.local_to_map(tile_map_layer.get_local_mouse_position())


func generate_tilemap(size: int) -> void:
	tile_map_layer.clear()

	for i in range(-size, size + 1):
		for j in range(-size, size + 1):
			if i == 0 and j == 0:
				continue

			var tile_index := abs((i + j) % 2)
			tile_map_layer.set_cell(Vector2i(j, i), 0, Vector2i(tile_index, 0),0)


func is_cell_in_bounds(position: Vector2i, size: int) -> bool:
	return tile_map_layer.get_used_rect().has_point(position)

func update_pattern_highlight() -> void:
	highlight_map_layer.clear()

	if pattern_resource == null:
		return

	var cells := pattern_resource.get_cells_at(Vector2i.ZERO, pattern_resource.current_direction)

	for cell in cells:
		if is_cell_in_bounds(cell, current_map_size):
			highlight_map_layer.set_cell(cell, 0, Vector2i(3, 0), 0)


func remove_out_of_bound_cells() -> void:
	if pattern_resource == null:
		return

	var pattern := pattern_resource.pattern

	for i in range(pattern.size() - 1, -1, -1):
		if not is_cell_in_bounds(pattern[i], current_map_size):
			pattern.remove_at(i)

	pattern_resource.pattern = pattern


func place_cell(cell_pos: Vector2i) -> void:
	if not is_cell_in_bounds(cell_pos, current_map_size):
		return

	if not pattern_resource.contains(cell_pos, pattern_resource.current_direction):
		pattern_resource.pattern.append(cell_pos)
		update_pattern_highlight()


func erase_cell(cell_pos: Vector2i) -> void:
	if not is_cell_in_bounds(cell_pos, current_map_size):
		return

	if pattern_resource.contains(cell_pos, pattern_resource.current_direction):
		pattern_resource.pattern.erase(cell_pos)
		update_pattern_highlight()



func _on_button_pressed() -> void:
	pattern_resource.set_and_update_direction(_next_direction())
	update_pattern_highlight()


func _next_direction() -> TilePatternResource.Direction:
	var next_direction := (pattern_resource.current_direction + 1) % 4
	return next_direction


func _on_clear_button_pressed() -> void:
	pattern_resource.pattern.clear()
	update_pattern_highlight()


func _on_set_size_button_pressed() -> void:
	var new_size: int = int(%SpinBox.value)
	set_tile_map_size(new_size)

func _on_change_size_button_pressed(new_size: int) -> void:
	set_tile_map_size(new_size)


func set_tile_map_size(new_size: int) -> void:
	generate_tilemap(new_size)
	current_map_size = new_size
	remove_out_of_bound_cells()
	update_pattern_highlight()


func _on_set_direction_pressed(dir: int) -> void:
	var direction: TilePatternResource.Direction = (TilePatternResource.Direction.values()[dir])
	pattern_resource.set_direction(direction)
	%DirectionLabel.text = (TilePatternResource.Direction.keys()[dir])
	update_pattern_highlight()


func _on_save_pattern_button_pressed() -> void:
	save_dialog.show()


func _on_save_dialog_file_selected(path: String) -> void:
	if not path.ends_with(".res"):
		path += ".res"

	ResourceSaver.save(pattern_resource, path)
	save_dialog.hide()


func _on_load_pattern_button_pressed() -> void:
	load_dialog.show()


func _on_load_dialog_file_selected(path: String) -> void:
	var res := ResourceLoader.load(path)

	if res is not TilePatternResource:
		push_error("Selected resource is not a TilePatternResource.")
		return

	pattern_resource = res.duplicate(true)

	remove_out_of_bound_cells()
	update_pattern_highlight()

	%DirectionLabel.text = (TilePatternResource.Direction.keys()[pattern_resource.current_direction])


func zoom_in() -> void:
	zoom_level += ZOOM_SPEED
	zoom_level = clamp(zoom_level, MIN_ZOOM, MAX_ZOOM)

	update_view()


func zoom_out() -> void:
	zoom_level -= ZOOM_SPEED
	zoom_level = clamp(zoom_level, MIN_ZOOM, MAX_ZOOM)

	update_view()


func reset_zoom() -> void:
	zoom_level = 1.0
	pan_offset = Vector2.ZERO

	update_view()


func update_view() -> void:
	var scale := Vector2(zoom_level, zoom_level)

	tile_map_layer.scale = scale
	tile_map_layer.position = pan_offset

	hover_layer.scale = scale
	hover_layer.position = pan_offset

	highlight_map_layer.scale = scale
	highlight_map_layer.position = pan_offset


func _on_reset_zoom_pressed() -> void:
	reset_zoom()