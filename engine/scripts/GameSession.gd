class_name GameSession
extends Container

var settlement: Settlement
var quest_board: QuestBoard
var money: int = 1000


func _ready() -> void:
	if quest_board is QuestBoard:
		quest_board.connect("quest_completed", _on_money_earned.bind(self))


func _on_money_earned(_quest: Quest, earnings: int, _event) -> void:
	money += earnings
