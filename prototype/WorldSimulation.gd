extends Node





func _ready():
	GameTick.set_speed(GameTick.SPEED.TRIPLE)
	GameTick.start_ticks()
