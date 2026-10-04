class_name TilePatternResource
extends Resource
## Stores the cell information and rotation of the pattern
##
## This class allows to rotate the pattern by 90 degree steps. Either by giving a preview of the rotated
## pattenrn or setting it directly
##

enum Direction {
    RIGHT = 0,
    DOWN = 1,
    LEFT = 2,
    UP = 3,
}

# pattern is stored here. (0,0) is always the origin cell
@export var pattern: Array[Vector2i]

# Direction determines what "forward" for a pattern is
# if you draw line to the right while the selected direction is right then the line points "forward"
@export var current_direction: Direction = Direction.RIGHT

# returns a preview of the pattern roated to a new direction
func get_pattern_for_direction(target_direction: Direction) -> Array[Vector2i]:
    var rotations_needed = (target_direction - current_direction) % 4
    if rotations_needed < 0:
      rotations_needed += 4
    var rotated_pattern: Array[Vector2i] = pattern.duplicate()

    for i in range(rotations_needed):
      rotated_pattern = rotate_pattern_by_90(rotated_pattern)
    return rotated_pattern

func contains(offset: Vector2i, direction: Direction = current_direction) -> bool:
  return offset in get_pattern_for_direction(direction)

func get_cells_at(origin: Vector2i = Vector2i(0,0), direction: Direction = current_direction) -> Array[Vector2i]:
  var cells: Array[Vector2i] = []
  for offset in get_pattern_for_direction(direction):
    cells.append(origin + offset)
  return cells

# returns a bounding box for the pattern
func get_bounds(direction: Direction = current_direction) -> Rect2i: 
  var cells := get_pattern_for_direction(direction)
  if cells.is_empty():
    return Rect2i()

  var min_x := cells[0].x
  var max_x := cells[0].x
  var min_y := cells[0].y
  var max_y := cells[0].y

  for cell in cells:
    min_x = mini(min_x, cell.x)
    max_x = maxi(max_x, cell.x)
    min_y = mini(min_y, cell.y)
    max_y = maxi(max_y, cell.y)

  return Rect2i(Vector2i(min_x, min_y), Vector2i(max_x - min_x + 1, max_y - min_y + 1) )

func rotate_by_90(clockwise: bool = true) -> Array[Vector2i]:
    var rotated_pattern: Array[Vector2i] = pattern.duplicate()
    for i in range(rotated_pattern.size()):
      var pos = rotated_pattern[i]
      if clockwise:
        rotated_pattern[i] = Vector2i(-pos.y, pos.x)
      else:
        rotated_pattern[i] = Vector2i(pos.y, -pos.x)
    return rotated_pattern

func rotate_pattern_by_90(pattern_to_rotate : Array[Vector2i], clockwise : bool = true) -> Array[Vector2i]:
  var rotated_pattern: Array[Vector2i] = pattern_to_rotate.duplicate()
  for i in range(rotated_pattern.size()):
    var pos = rotated_pattern[i]
    if clockwise:
      rotated_pattern[i] = Vector2i(-pos.y, pos.x)
    else:
      rotated_pattern[i] = Vector2i(pos.y, -pos.x)
  return rotated_pattern

# this mutates the state of the pattern
func set_direction(target_direction: Direction) -> void:
  var rotated_pattern := get_pattern_for_direction(target_direction)
  pattern = rotated_pattern
  current_direction = target_direction

func get_current_pattern_state() -> Array[Vector2i]:
    return get_pattern_for_direction(current_direction)
