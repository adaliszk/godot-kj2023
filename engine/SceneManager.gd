extends Node

var LAST_SCENE: String = "res://scenes/MainScreen.tscn"


func load_scene(scene: PackedScene) -> void:
	LAST_SCENE = get_tree().get_current_scene().scene_file_path
	get_tree().change_scene_to_packed(scene)


func load_previous_scene() -> void:
	get_tree().change_scene_to_file(LAST_SCENE)
