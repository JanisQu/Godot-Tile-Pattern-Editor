@tool
extends Control


@onready var highlight_layer: TileMapLayer = %HoverLayer
@onready var tile_map_layer: TileMapLayer = %TileMapLayer
@onready var highlight_map_layer: TileMapLayer = %HighlightMapLayer
@onready var save_dialog: FileDialog = $SaveDialog
@onready var load_dialog: FileDialog = $LoadDialog

var last_cell_pos : = Vector2i(0,0)
var current_pattern : Array[Vector2i]
var current_map_size := 3
var pattern_resource : TilePatternResource

var is_drawing := false
var is_earasing := false

func _ready() -> void:
  generate_tilemap(current_map_size)
  set_tile_map_size(current_map_size)
  pattern_resource = TilePatternResource.new()


func _process(delta: float) -> void:
  highlight_layer.erase_cell(last_cell_pos)
  var cell_pos = highlight_layer.local_to_map(highlight_layer.get_local_mouse_position())
  if is_cell_in_bounds(cell_pos, current_map_size):
    highlight_layer.set_cell(cell_pos, 0, Vector2i(2, 0), 0)
  last_cell_pos = cell_pos


func _input(event: InputEvent) -> void:
  if not visible : 
    return
 
  var mouse_pos = tile_map_layer.get_local_mouse_position()
  var cell_pos = tile_map_layer.local_to_map(mouse_pos)
  var in_bounds = is_cell_in_bounds(cell_pos, current_map_size)
  
  if event is InputEventMouseButton:
    if event.button_index == MOUSE_BUTTON_LEFT:
      if event.pressed and in_bounds:
        is_drawing = true
        place_cell(cell_pos)
      else:
        is_drawing = false 
        
    if event.button_index == MOUSE_BUTTON_RIGHT:
      if event.pressed and in_bounds:
        is_earasing = true
        earase_cell(cell_pos)
      else:
        is_earasing = false 

    # Handle continuous drawing while the mouse is moving and the button is pressed
  if event is InputEventMouseMotion and is_drawing:
    place_cell(cell_pos)   

  if event is InputEventMouseMotion and is_earasing and not is_drawing:
    earase_cell(cell_pos)
      

func generate_tilemap(size : int):
  tile_map_layer.clear()
  for i in range(-size, size + 1):
    for j in range(-size, size + 1):
      if (i == 0 and j == 0):
        continue
      # Alternate between tiles
      var tile_index = abs((i + j) % 2)
      tile_map_layer.set_cell(Vector2i(j,i),0, Vector2i(tile_index, 0), 0)

func is_cell_in_bounds(position: Vector2i, size: int) -> bool:
   return tile_map_layer.get_used_rect().has_point(position)

func update_pattern_highlight() -> void:
  for i in range(-current_map_size, current_map_size + 1):
    for j in range(-current_map_size, current_map_size + 1):
      var cell_pos = Vector2i(j,i)
      
      highlight_map_layer.erase_cell(cell_pos)
      if current_pattern.has(cell_pos):
        highlight_map_layer.set_cell(cell_pos, 0, Vector2i(3, 0), 0)
        
func remove_out_of_bound_cells() -> void:
  # to prevent runtime array modification errors
  var current_pattern_copy := current_pattern.duplicate()
  for i in range(current_pattern.size() -1, -1, -1 ):
    if not is_cell_in_bounds(current_pattern[i], current_map_size):
      current_pattern_copy.remove_at(i)
  current_pattern = current_pattern_copy
    
func place_cell(cell_pos : Vector2i) -> void:
  if is_cell_in_bounds(cell_pos, current_map_size):
    if not current_pattern.has(cell_pos):
      current_pattern.append(cell_pos)
      highlight_map_layer.set_cell(cell_pos, 0, Vector2i(3, 0), 0)
      pattern_resource.pattern = current_pattern
      
func earase_cell(cell_pos : Vector2i) -> void:
  if is_cell_in_bounds(cell_pos, current_map_size):
    if current_pattern.has(cell_pos):
      #var cell_coords = tile_map_layer.get_cell_atlas_coords(cell_pos)
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

func _on_change_size_button_pressed(new_size : int) -> void:
  generate_tilemap(new_size)
  current_map_size = new_size
  
  var scale_factor = 1.0 / float(new_size) * 7.0  # Adjust the constant factor as needed
  tile_map_layer.scale = Vector2(scale_factor, scale_factor)
  highlight_layer.scale = Vector2(scale_factor, scale_factor)
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
  pattern_resource = res
  current_pattern = pattern_resource.pattern
  remove_out_of_bound_cells()
  update_pattern_highlight()

func set_tile_map_size(new_size : int) -> void:
  generate_tilemap(new_size)
  current_map_size = new_size
  
  var scale_factor = 1.0 / float(new_size) * 7.0  # Adjust the constant factor as needed
  tile_map_layer.scale = Vector2(scale_factor, scale_factor)
  highlight_layer.scale = Vector2(scale_factor, scale_factor)
  highlight_map_layer.scale = Vector2(scale_factor, scale_factor)
  remove_out_of_bound_cells()
  update_pattern_highlight()


func _on_set_size_button_pressed() -> void:
  var new_size : int = int(%SpinBox.value)
  set_tile_map_size(new_size)
  


func _on_set_direction_pressed(dir: int) -> void:
  var direction : TilePatternResource.Direction = TilePatternResource.Direction.keys()[dir]
  pattern_resource.set_and_update_direction(direction)
  current_pattern = pattern_resource.pattern
  update_pattern_highlight()


func _on_set_direction_right_pressed() -> void:
  pass # Replace with function body.
