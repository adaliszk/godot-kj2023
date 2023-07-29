class_name GameSession
extends Node

var settlement: Settlement
var quest_board: QuestBoard
var money: int = 1000


func _ready() -> void:
	if quest_board is QuestBoard:
		quest_board.connect("quest_completed", _on_money_earned.bind(self))

	GameTick.start()


func _unhandled_key_input(event) -> void:
	if event.is_action_pressed("game_pause"):
		GameTick.speed = GameTick.TurnSpeed.PAUSE
	if event.is_action_pressed("game_speed_normal"):
		GameTick.speed = GameTick.TurnSpeed.NORMAL
	if event.is_action_pressed("game_speed_double"):
		GameTick.speed = GameTick.TurnSpeed.DOUBLE
	if event.is_action_pressed("game_speed_triple"):
		GameTick.speed = GameTick.TurnSpeed.TRIPLE

	if OS.is_debug_build() and event.is_action_pressed("game_speed_ultra"):
		GameTick.speed = GameTick.TurnSpeed.ULTRA


func _on_money_earned(_quest: Quest, earnings: int, _event) -> void:
	money += earnings
