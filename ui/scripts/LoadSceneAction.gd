extends Button

@export var scene: PackedScene


func _pressed() -> void:
	Game.load_scene(scene)
