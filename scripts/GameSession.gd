extends Node

signal settlement_connected
signal quest_board_connected

@export var should_start_gametick: bool = false
@export var score: int = 0

var settlement: Town
var quest_board: QuestBoard


func set_settlement(town: Town) -> void:
	settlement = town
	emit_signal("settlement_connected")


func set_quest_board(board: QuestBoard) -> void:
	quest_board = board
	emit_signal("quest_board_connected")
