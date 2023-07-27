@tool
class_name Settlement
extends TileMapLocation

@export var quest_board: QuestBoard
@export var tavern: Tavern

@export var max_population: int = 24
@export var population: int:
	get:
		return units.size()

var units: Array:
	get:
		#TODO(KISS): Try finding a better solution for this
		units = []
		for child in get_children():
			if child is Unit:
				units.append(child)
		return units
