extends Label


func _ready():
	update()

func _process(_delta):
	update()


func update() -> void:
	self.text = "%s (%s/%s)" % [
		GameTick.get_turn(),
		GameTick.get_max_cycle(),
		GameTick.get_cycle(),
	]
