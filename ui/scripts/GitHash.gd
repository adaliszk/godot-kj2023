extends Label


func _ready():
	var file = FileAccess.open("res://GIT_HASH.txt", FileAccess.READ)
	var content = file.get_as_text()
	self.text = "#%s" % content
