class_name TilePatternResource
extends Resource


enum Direction {
    Right = 0,
    Up = 1,
    Left = 2,
    Down = 3
}


@export var pattern: Array[Vector2i]
@export var current_direction: Direction = Direction.Right  

func set_direction_preview(target_direction: Direction) -> Array[Vector2i]:
    var rotations_needed = (target_direction - current_direction) % 4
    if rotations_needed < 0:
      rotations_needed += 4  
    var rotated_pattern: Array[Vector2i] = pattern.duplicate()  

    for i in range(rotations_needed):
      rotated_pattern = rotate_by_90(true)  
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

func get_current_pattern_state() -> Array[Vector2i]:
    return set_direction_preview(current_direction)
