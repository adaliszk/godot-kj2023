extends Label


func _process(_delta):
	text = "Turn %s (%s/%s)" % [
		GameTick.turn,
		GameTick.CYCLE_PER_TURN,
		GameTick.cycle,
	]
