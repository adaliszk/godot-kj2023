extends Node

@export var camera: Camera3D
@export var camera_speed = 3.0

var focus_position: Vector3


func _ready() -> void:
	if camera:
		focus_position = camera.global_transform.origin


func _process(delta) -> void:
	var direction = (
		Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down").normalized()
	)
	var x = direction.x / 3 + direction.y / 2
	var y = direction.y / 3 - direction.x / 2

	if direction == Vector2.ZERO:
		focus_position = camera.global_transform.origin + Vector3(x, 0, y) * camera_speed
	else:
		focus_position += Vector3(x, 0, y)

	if focus_position == camera.global_transform.origin:
		return

	var focus_xform = Transform3D(camera.global_transform.basis, focus_position)
	camera.global_transform = camera.global_transform.interpolate_with(
		focus_xform, camera_speed * delta
	)

	# var target_xform = target.translated_local(offset)
	# camera.global_transform = camera.global_transform.interpolate_with(target_xform, lerp_speed * delta)
	# camera.look_at(target.global_transform.origin, target.transform.basis.y)
