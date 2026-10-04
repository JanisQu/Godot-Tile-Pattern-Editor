extends Node2D


const PATTERN_1: TilePatternResource = preload(
	"res://addons/TilePatternEditor/Resources/Pattern/arrow_pattern.res"
)

const PATTERN_2: TilePatternResource = preload(
	"res://addons/TilePatternEditor/Resources/Pattern/trail_pattern.res"
)

const PATTERN_3: TilePatternResource = preload(
	"res://addons/TilePatternEditor/Resources/Pattern/line_pattern.res"
)


@onready var button1: Button = %ButtonPattern1
@onready var button2: Button = %ButtonPattern2
@onready var button3: Button = %ButtonPattern3

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var preview_tile_map_layer: TileMapLayer = $PreviewTileMapLayer


const SOURCE_ID: int = 0
const ALTERNATIVE_TILE: int = 0

@export var atlas_coords: Vector2i = Vector2i.ZERO


var current_pattern: TilePatternResource
var preview_direction: TilePatternResource.Direction = TilePatternResource.Direction.RIGHT

var hover_cell: Vector2i = Vector2i.ZERO
var preview_cells: Array[Vector2i] = []


func _process(_delta: float) -> void:
	var mouse_cell := tile_map_layer.local_to_map(
		tile_map_layer.get_local_mouse_position()
	)

	if mouse_cell != hover_cell:
		hover_cell = mouse_cell
		_update_preview()


func _input(event: InputEvent) -> void:

	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				_select_pattern(PATTERN_1)

			KEY_2:
				_select_pattern(PATTERN_2)

			KEY_3:
				_select_pattern(PATTERN_3)

			KEY_Q:
				if current_pattern != null:
					_rotate_preview(-1)

			KEY_E:
				if current_pattern != null:
					_rotate_preview(1)

	if event is InputEventMouseButton and event.pressed:
		if current_pattern == null:
			return

		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_place_pattern()

			MOUSE_BUTTON_RIGHT:
				_erase_pattern()

			MOUSE_BUTTON_WHEEL_UP:
				_rotate_preview(1)

			MOUSE_BUTTON_WHEEL_DOWN:
				_rotate_preview(-1)


func _select_pattern(pattern_resource: TilePatternResource) -> void:
	current_pattern = pattern_resource
	preview_direction = current_pattern.current_direction
	_update_preview()


func _on_button_pattern_1_pressed() -> void:
	_select_pattern(PATTERN_1)


func _on_button_pattern_2_pressed() -> void:
	_select_pattern(PATTERN_2)


func _on_button_pattern_3_pressed() -> void:
	_select_pattern(PATTERN_3)

func _rotate_preview(amount: int) -> void:
	preview_direction = (preview_direction + amount) % 4

	if preview_direction < 0:
		preview_direction += 4

	_update_preview()


func _update_preview() -> void:
	_clear_preview()

	if current_pattern == null:
		return

	preview_cells = current_pattern.get_cells_at(hover_cell, preview_direction)

	for cell in preview_cells:
		preview_tile_map_layer.set_cell(cell, SOURCE_ID, atlas_coords, ALTERNATIVE_TILE)

	if not current_pattern.contains(Vector2i.ZERO, preview_direction):
		preview_tile_map_layer.set_cell(hover_cell, SOURCE_ID, Vector2i(2, 0), 0)
		preview_cells.append(hover_cell)

	_update_bounds_preview()


func _clear_preview() -> void:
	for cell in preview_cells:
		preview_tile_map_layer.erase_cell(cell)
	preview_cells.clear()


func _update_bounds_preview() -> void:
	# Example of using get_bounds() 
	# not actually used here
	var bounds := current_pattern.get_bounds(preview_direction)
	var top_left := hover_cell + bounds.position
	var bottom_right := top_left + bounds.size - Vector2i.ONE
	


func _place_pattern() -> void:
	if current_pattern == null:
		return

	var cells := current_pattern.get_cells_at(hover_cell, preview_direction)

	for cell in cells:
		tile_map_layer.set_cell(cell, SOURCE_ID, atlas_coords, 0)

func _erase_pattern() -> void:
	if current_pattern == null:
		return

	var cells := current_pattern.get_cells_at(hover_cell, preview_direction)

	for cell in cells:
		tile_map_layer.erase_cell(cell)
