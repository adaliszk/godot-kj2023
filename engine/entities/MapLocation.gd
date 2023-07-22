class_name MapLocation
extends Node2D


@export_group("Map")
@export var map: TileMap
@export var tile: Vector2i:
	set(coords): _position = coords
	get: return _position

@export_group("Data")
@export var UNITS: Array = []


var _position: Vector2i
var _map: TileMap


func _ready():
	GameTick.connect("turn_tick", _on_turn_tick.bind(self))
	GameTick.connect("cycle_tick", _on_cycle_tick.bind(self))
	GameTick.connect("day_tick", _on_day_tick.bind(self))
	GameTick.connect("night_tick", _on_night_tick.bind(self))
	
	_map = map
	
	var tile_coords: Vector2 = (_map.map_to_local(tile) * _map.scale)
	position = Vector2(
		tile_coords.x + _map.position.x,
		tile_coords.y + _map.position.y
	)

func _on_turn_tick(_state: int, _event) -> void:
	pass

func _on_cycle_tick(_state: int, _event) -> void:
	pass

func _on_day_tick(_state: int, _event) -> void:
	pass

func _on_night_tick(_state: int, _event) -> void:
	pass

func _on_focus():
	pass

func _on_blur():
	pass

func _on_input(_viewport, event: InputEvent, _shape_idx):
	if event.is_action_pressed("ui_select"): _on_trigger()
	if event.is_action_pressed("ui_menu"): _on_trigger()

func _on_trigger():
	pass

func _on_context():
	pass
