extends Label


func _ready():
	update()

func _process(_delta):
	update()


func update() -> void:
	self.text = "%s (%s/%s)" % [
		Events.get_turn(),
		Events.get_max_cycle(),
		Events.get_cycle(),
	]
