extends Button

@export var scene: PackedScene


func _pressed() -> void:
	SceneManager.load_scene(scene)
