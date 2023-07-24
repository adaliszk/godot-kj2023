extends Label


func _ready() -> void:
	GameSession.connect("settlement_connected", _on_session.bind(self))
	if GameSession.settlement:
		_on_session(null)


func _on_session(_event) -> void:
	if GameSession.settlement:
		GameSession.settlement.connect("population_changed", _on_population_changed.bind(self))
		_on_population_changed(null)


func _on_population_changed(_event):
	text = (
		"%s/%s" % [GameSession.settlement.populationMax, GameSession.settlement.populationCurrent]
	)
