extends Label


func _ready():
	update()

func _process(_delta):
	update()


func update() -> void:
	self.text = "%s" % Events.get_turn()
