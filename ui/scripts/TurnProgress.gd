extends Label


func _ready():
	update()


func _process(_delta):
	update()


func update() -> void:
	var max_cycle = GameTick.get_max_cycle()
	var cycle = GameTick.get_cycle()
	var progress = max_cycle - cycle
	self.text = "%s0%s" % ["-".repeat(cycle), "-".repeat(progress)]
