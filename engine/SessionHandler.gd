class_name SessionHandler
extends Node

signal session_connected

@export var should_start_gametick: bool = false

@export var quest_board: QuestBoard
@export var settlement: Town


func _ready() -> void:
	if should_start_gametick:
		GameTick.reset_ticks()
		GameTick.start_ticks()


func update_session() -> void:
	Log.debug("SessionHandler#%s::update_session()" % name)

	if quest_board != null:
		GameSession.set_quest_board(quest_board)

	if settlement != null:
		GameSession.set_settlement(settlement)

	emit_signal("session_connected")
