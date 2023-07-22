class_name LocationWithDialogue
extends MapLocation


@export var pinned: bool = false


func _ready():
	super._ready()
	close()


func open():
	_update_dialogue()
	$Dialogue.show()


func close():
	if pinned: return
	$Dialogue.hide()


func set_pinned(state):
	pinned = state


func _on_focus() -> void:
	super._on_focus()
	open()


func _on_blur() -> void:
	super._on_blur()
	close()


func _update_dialogue() -> void:
	pass
