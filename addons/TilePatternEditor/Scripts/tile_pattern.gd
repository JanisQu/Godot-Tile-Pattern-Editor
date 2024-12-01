class_name TilePatternResource
extends Resource
## Stores the cell information and rotation of the pattern
##
## This class allows to rotate the pattern 90 degrees. Either by giving a preview of the rotated
## pattenr or setting it directly
##

enum Direction {
    Right = 0,
    Down = 1,
    Left = 2,
    Up = 3,
}


@export var pattern: Array[Vector2i]
@export var current_direction: Direction = Direction.Right

func set_direction_preview(target_direction: Direction) -> Array[Vector2i]:
    var rotations_needed = (target_direction - current_direction) % 4
    if rotations_needed < 0:
      rotations_needed += 4
    var rotated_pattern: Array[Vector2i] = pattern.duplicate()

    for i in range(rotations_needed):
      rotated_pattern = rotate_pattern_by_90(rotated_pattern)
    return rotated_pattern

func set_and_update_direction(target_direction: Direction) -> void:
    var rotated_pattern = set_direction_preview(target_direction)

    pattern = rotated_pattern
    current_direction = target_direction

    print_debug("Pattern after update: ", pattern)

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

func get_current_pattern_state() -> Array[Vector2i]:
    return set_direction_preview(current_direction)
