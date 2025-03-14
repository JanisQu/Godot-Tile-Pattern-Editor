@tool
extends EditorPlugin

const addon_path:String = "res://addons/TilePatternEditor"

var pattern_edior : Control = load(addon_path.path_join("Scenes/pattern_editor.tscn")).instantiate()



func _enter_tree() -> void:

  add_control_to_bottom_panel(pattern_edior, "TilePattern")



func _exit_tree() -> void:
  remove_control_from_bottom_panel(pattern_edior)
  pattern_edior.queue_free()
