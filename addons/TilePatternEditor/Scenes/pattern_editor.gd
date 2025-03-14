@tool
extends Control

@onready var hover_layer: TileMapLayer = %HoverLayer
@onready var tile_map_layer: TileMapLayer = %TileMapLayer
@onready var highlight_map_layer: TileMapLayer = %HighlightMapLayer
@onready var save_dialog: FileDialog = $SaveDialog
@onready var load_dialog: FileDialog = $LoadDialog
@onready var zoom_control: Control = %ZoomControl

var last_cell_pos := Vector2i(0, 0)
var current_pattern: Array[Vector2i]
var current_map_size := 3
var pattern_resource: TilePatternResource

var is_drawing := false
var is_erasing := false

# Zoom variables
var zoom_level: float = 1.0
const ZOOM_SPEED: float = 0.1
const MIN_ZOOM: float = 0.1
const MAX_ZOOM: float = 4.0
var pan_offset: Vector2 = Vector2.ZERO  # Optional, for panning

func _ready() -> void:
    generate_tilemap(current_map_size)
    set_tile_map_size(current_map_size)
    pattern_resource = TilePatternResource.new()

func _process(delta: float) -> void:
    hover_layer.erase_cell(last_cell_pos)
    var cell_pos = hover_layer.local_to_map(hover_layer.get_local_mouse_position())
    if is_cell_in_bounds(cell_pos, current_map_size):
        hover_layer.set_cell(cell_pos, 0, Vector2i(2, 0), 0)
    last_cell_pos = cell_pos

func _input(event: InputEvent) -> void:
    if not visible:
        return

    # Handle zoom input
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            zoom_in()
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            zoom_out()
       # elif event.button_index == MOUSE_BUTTON_MIDDLE:  # Optional: Reset zoom
       #     reset_zoom()

    # Handle panning
    if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
        pan_offset += event.relative
        update_view()

    # Placing the cell
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            var cell_pos : Vector2i = get_cell_pos_from_mouse()
            if event.pressed and is_cell_in_bounds(cell_pos, current_map_size):
                is_drawing = true
                place_cell(cell_pos)
            else:
                is_drawing = false

        # Erasing the cell
        if event.button_index == MOUSE_BUTTON_RIGHT:
            var cell_pos : Vector2i = get_cell_pos_from_mouse()
            if event.pressed and is_cell_in_bounds(cell_pos, current_map_size):
                is_erasing = true
                erase_cell(cell_pos)
            else:
                is_erasing = false

    # Handle continuous drawing while the mouse is moving and the button is pressed
    if event is InputEventMouseMotion and is_drawing:
        place_cell(get_cell_pos_from_mouse())

    if event is InputEventMouseMotion and is_erasing and not is_drawing:
        erase_cell(get_cell_pos_from_mouse())

func get_cell_pos_from_mouse() -> Vector2i:
    return tile_map_layer.local_to_map(tile_map_layer.get_local_mouse_position())

func generate_tilemap(size: int):
    tile_map_layer.clear()
    for i in range(-size, size + 1):
        for j in range(-size, size + 1):
            if i == 0 and j == 0:
                continue
            # Alternate between tiles creating the checker board
            var tile_index = abs((i + j) % 2)
            tile_map_layer.set_cell(Vector2i(j, i), 0, Vector2i(tile_index, 0), 0)

func is_cell_in_bounds(position: Vector2i, size: int) -> bool:
    return tile_map_layer.get_used_rect().has_point(position)

func update_pattern_highlight() -> void:
    for i in range(-current_map_size, current_map_size + 1):
        for j in range(-current_map_size, current_map_size + 1):
            var cell_pos = Vector2i(j, i)
            highlight_map_layer.erase_cell(cell_pos)
            if current_pattern.has(cell_pos):
                highlight_map_layer.set_cell(cell_pos, 0, Vector2i(3, 0), 0)

func remove_out_of_bound_cells() -> void:
    var current_pattern_copy := current_pattern.duplicate()
    for i in range(current_pattern.size() - 1, -1, -1):
        if not is_cell_in_bounds(current_pattern[i], current_map_size):
            highlight_map_layer.erase_cell(current_pattern[i])
            current_pattern_copy.remove_at(i)
    current_pattern = current_pattern_copy

func place_cell(cell_pos: Vector2i) -> void:
    if is_cell_in_bounds(cell_pos, current_map_size):
        if not current_pattern.has(cell_pos):
            current_pattern.append(cell_pos)
            highlight_map_layer.set_cell(cell_pos, 0, Vector2i(3, 0), 0)
            pattern_resource.pattern = current_pattern

func erase_cell(cell_pos: Vector2i) -> void:
    if is_cell_in_bounds(cell_pos, current_map_size):
        if current_pattern.has(cell_pos):
            highlight_map_layer.erase_cell(cell_pos)
            current_pattern.erase(cell_pos)
            pattern_resource.pattern = current_pattern

func _on_button_pressed() -> void:
    current_pattern = pattern_resource.rotate_by_90()
    pattern_resource.pattern = current_pattern
    update_pattern_highlight()

func _on_clear_button_pressed() -> void:
    current_pattern.clear()
    update_pattern_highlight()

func _on_change_size_button_pressed(new_size: int) -> void:
    generate_tilemap(new_size)
    current_map_size = new_size
    remove_out_of_bound_cells()
    update_pattern_highlight()

func _on_save_pattern_button_pressed() -> void:
    save_dialog.show()

func _on_save_dialog_file_selected(path: String) -> void:
    if not path.ends_with(".res"):
        path += ".res"
    ResourceSaver.save(pattern_resource, path, ResourceSaver.FLAG_NONE)
    save_dialog.hide()

func _on_load_pattern_button_pressed() -> void:
    load_dialog.show()

func _on_load_dialog_file_selected(path: String) -> void:
    var res = ResourceLoader.load(path)
    pattern_resource = res.duplicate()
    current_pattern = pattern_resource.pattern.duplicate()
    remove_out_of_bound_cells()
    update_pattern_highlight()

func set_tile_map_size(new_size: int) -> void:
    generate_tilemap(new_size)
    current_map_size = new_size
    remove_out_of_bound_cells()
    update_pattern_highlight()

func _on_set_size_button_pressed() -> void:
    var new_size: int = int(%SpinBox.value)
    set_tile_map_size(new_size)

func _on_set_direction_pressed(dir: int) -> void:
    var direction: TilePatternResource.Direction = TilePatternResource.Direction.values()[dir]
    pattern_resource.set_and_update_direction(direction)
    current_pattern = pattern_resource.pattern
    %DirectionLabel.text = TilePatternResource.Direction.keys()[dir]
    update_pattern_highlight()

# Zoom functionality
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
    tile_map_layer.scale = Vector2(zoom_level, zoom_level)
    tile_map_layer.position = pan_offset
    hover_layer.scale = Vector2(zoom_level, zoom_level)
    hover_layer.position = pan_offset
    highlight_map_layer.scale = Vector2(zoom_level, zoom_level)
    highlight_map_layer.position = pan_offset


func _on_reset_zoom_pressed() -> void:
  reset_zoom()
