@tool
class_name TileMapLocation
extends Node2D

var map: TileMap


func _ready():
	GameTick.connect("cycle_tick", _on_cycle_tick.bind(self))
	GameTick.connect("turn_tick", _on_turn_tick.bind(self))


func _physics_process(_delta):
	if Engine.is_editor_hint() and map:
		position = map.map_to_local(map.local_to_map(position))


func _enter_tree():
	map = get_parent() if get_parent() is TileMap else null
	if Engine.is_editor_hint():
		update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	if not map is TileMap:
		return ["This node needs to be a child of a `TileMap` to work properly."]
	return []


func _on_cycle_tick(_cycle: int, _event):
	pass


func _on_turn_tick(_cycle: int, _event):
	pass
