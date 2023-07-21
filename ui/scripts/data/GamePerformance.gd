extends Label


func _process(_delta): 
	var cpu_time = Performance.get_monitor(Performance.TIME_PROCESS)
	var gpu_time = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	
	self.text = "%s/%s (%sfps)" % [
			snapped(cpu_time * 1000, 0.01),
			snapped(gpu_time * 1000, 0.01),
			fps
		]
