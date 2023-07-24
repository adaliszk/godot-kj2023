extends Label


func _ready() -> void:
	GameSession.connect("quest_board_connected", _on_session.bind(self))
	if GameSession.quest_board:
		_on_session(null)


func _on_session(_event) -> void:
	if GameSession.quest_board:
		GameSession.quest_board.connect("board_updated", _on_quests_changed.bind(self))
		_on_quests_changed(null)


func _on_quests_changed(_event):
	text = (
		"%s/%s/%s"
		% [
			GameSession.quest_board.maxQuests,
			GameSession.quest_board.quests.size(),
			GameSession.quest_board.questsCompleted
		]
	)
