@tool
extends EditorPlugin

func _enter_tree() -> void:
	print("BSC Plugin Enabled")

func _exit_tree() -> void:
	print("BSC Plugin Disabled")
