extends GridContainer


var quest_card = preload("res://ui/components/QuestCard/QuestCard.tscn")


func _ready() -> void:
	GameSession.connect("quest_board_connected", _on_board_connected.bind(self))
	if GameSession.quest_board:
		_on_board_connected(null)
	

func _on_board_connected(_event) -> void:
	GameSession.quest_board.connect("board_updated", _on_board_updated.bind(self))


func _on_board_updated(_event) -> void:
	render_quests()


func clear_canvas() -> void:
	for card in get_children():
		card.queue_free()


func render_quests() -> void:
	if not GameSession.quest_board:
		return

	clear_canvas()
	for quest in GameSession.quest_board.quests:
		var card = quest_card.instantiate()
		card.quest = quest
		add_child(card)
		card.update_data()
