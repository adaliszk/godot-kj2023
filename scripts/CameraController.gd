extends Camera2D


@export var speed = 1250


func _process(delta) -> void:
    var input_dir = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
    position += input_dir * self.speed * delta