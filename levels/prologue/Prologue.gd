extends Node

@onready var dialogue = $Canvas/Container/Dialogue


var CURRENT_LINE: int = 0
const LINES = [
	"I used to be an adventurer...",
	"but then I took an arrow to the knee...",
	"...",
	"That is when I decided to retire...",
	"but the guild assigned me my own town as the master instead."
]


func _ready() -> void:
	render_dialogue()


func _input(_event) -> void:
	if Input.is_action_just_pressed('ui_accept'):
		CURRENT_LINE = CURRENT_LINE + 1
		
		if CURRENT_LINE >= len(LINES):
			queue_free()
			return
		
		render_dialogue()


func render_dialogue():
	dialogue.text = LINES[CURRENT_LINE]
