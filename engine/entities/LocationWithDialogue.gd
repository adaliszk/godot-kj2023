class_name LocationWithDialogue
extends MapLocation

@export var pinned: bool = false


func _ready() -> void:
	close()


func open() -> void:
	_update_dialogue()
	$Dialogue.show()


func close() -> void:
	if pinned:
		return
	$Dialogue.hide()


func set_pinned(state) -> void:
	pinned = state


func _on_focus() -> void:
	open()


func _on_blur() -> void:
	close()


func _update_dialogue() -> void:
	pass
