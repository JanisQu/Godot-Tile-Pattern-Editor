# Tile Pattern Editor Addon for Godot

This addon adds a simple Tile Pattern Editor to the Godot Editor, enabling the creation and manipulation of tile patterns for use in tile-based games or systems.

Store patterns as Vector2i arrays in a custom TilePatternResource.
TilePatternResource supports rotation and directional handling procrammatically or through the edior.


## Installation

1. Download or clone the repository.
2. Copy the addons folder into your Godot project.
3. In the Godot Editor, go to Project -> Project Settings -> Plugins.
4. Enable the Tile Pattern Editor plugin from the list.

## Usage

Once the addon is enabled, you'll have access to the Tile Pattern Editor in the Godot Editor. To create a new pattern:

Open the Tile Pattern Editor (At the Bottom) and start drawing your pattern using the tools provided.
Rotate and set the direction of the pattern using the UI controls or programmatically within your game code.

## API Overview
TilePatternResource

A custom resource used to store and manipulate tile patterns. Patterns are stored as an array of Vector2i positions representing tile coordinates.

### Properties:
* **pattern**: Array[Vector2i]: The current array of tile positions.
* **current_direction**: Direction: The direction the pattern is currently facing (Right, Up, Left, Down).
  

### Methods:
* **set_direction_preview(target_direction: Direction) -> Array[Vector2i]**: Returns what the pattern would look like if rotated to the target_direction, without modifying the current state.
* **set_and_update_direction(target_direction: Direction) -> void**: Rotates the pattern to the target_direction and updates the current_direction.
* **rotate_by_90(clockwise: bool = true) -> Array[Vector2i]**: Rotates the pattern by 90 degrees clockwise or counterclockwise.
* **get_current_pattern_state() -> Array[Vector2i]:** Returns the current pattern rotated to its current direction.

## License 
This project is licensed under the MIT License.
