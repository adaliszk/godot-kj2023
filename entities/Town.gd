class_name Town
extends LocationWithDialogue

@onready var display_name = $Dialogue/Spacer/Container/Data/DisplayName
@onready var population_label = $Dialogue/Spacer/Container/Data/Header/Population
@onready var debug_info = $Dialogue/Spacer/Container/DebugInfo

var aventurer = preload("res://entities/Adventurer.tscn")


var POPULATION: int = 25
var SIZE: int = 50


var QUESTS_DONE: int = 0
var QUESTS: Array = []



func _on_day_tick(_state: int, _event) -> void:
	# Updating adventurers
	for unit in UNITS:
		unit._on_tick()


func _on_turn_tick(_state: int, _event) -> void:
	tick()


func tick() -> void:
	var rng = RandomNumberGenerator.new()

	# Migrate population
	if (SIZE - (POPULATION + len(UNITS))) > 0:
		POPULATION += rng.randi_range(1, 5)

	# Spawning Adventurers
	if round(POPULATION / 2) > len(UNITS):
		var newbies = rng.randi_range(0, 5)
		for n in range(newbies):
			var unit = aventurer.instantiate()
			unit.set_map_location(self._map, self)
			UNITS.append(unit)
			add_child(unit)

		POPULATION -= newbies
		print(name, " spawned ", newbies, " new adventurers!")

	# Spawning Quests
	if len(UNITS) > 0:
		var quests = rng.randi_range(1, 3)
		var locations = []
		
		for target in get_parent().get_children():
			locations.append(target)
		
		for n in range(quests):
			var target = locations.pick_random()
			QUESTS.append(Quest.new(self, target))
		
		print(name, " sent ", quests, " new quests!")

	# Abandoning Quests due to them taking too long to be picked
	if len(QUESTS) > POPULATION * 2:
		var abandon = round(len(QUESTS) - POPULATION * 1.5)
		for n in range(abandon):
			var q = QUESTS.pick_random()
			QUESTS.remove_at(QUESTS.find(q))
			q.queue_free()
		print(name, " ABADONED ", abandon, " quests!")

	_update_dialogue()


func _update_dialogue() -> void:
	display_name.text = name
	population_label.text = "%s/%s" % [SIZE, POPULATION + len(UNITS)]
	_update_debug_info()


func _update_debug_info() -> void:
	debug_info.text = "Units(%s) Quests(%s/%s)" % [
			len(UNITS), len(QUESTS), QUESTS_DONE
		]
