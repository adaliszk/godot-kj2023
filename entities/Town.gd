class_name Town
extends LocationWithDialogue

@onready var display_name = $Dialogue/Spacer/Container/Data/DisplayName
@onready var population_label = $Dialogue/Spacer/Container/Data/Header/Population
@onready var debug_info = $Dialogue/Spacer/Container/DebugInfo

var aventurer = preload("res://entities/Adventurer.tscn")


@export var POPULATION: int = 2
@export var SIZE: int = 5


@export var QUEST_MIN_TIER: Rank.TIER = Rank.TIER.F
@export var QUEST_MAX_TIER: Rank.TIER = Rank.TIER.F
@export var QUESTS_DONE: int = 0
var QUESTS: Array = []


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
			unit.set_map_location(self)

			# Update Quest Tiers
			if unit.rank < QUEST_MAX_TIER:
				QUEST_MAX_TIER = unit.rank
			
			UNITS.append(unit)
			add_child(unit)

		POPULATION -= newbies
		print(name, " spawned ", newbies, " new adventurers!")

	# Spawning Quests
	if len(UNITS) > 0:
		var quests = rng.randi_range(0, 3)
		var locations = []
		
		for target in get_parent().get_children():
			locations.append(target)
		
		for n in range(quests):
			var target = locations.pick_random()
			QUESTS.append(Quest.new(self, target, QUEST_MIN_TIER, QUEST_MAX_TIER))

	# Abandoning Quests due to them taking too long to be picked
	if len(QUESTS) > POPULATION * 4:
		var abandon = round(len(QUESTS) - POPULATION * 2)
		for n in range(abandon):
			if len(QUESTS) == 0:
				break
			var q = QUESTS.pick_random()
			QUESTS.remove_at(QUESTS.find(q))
			QUESTS_DONE -= 1
			if q:
				q.queue_free()
		print(name, " ABADONED ", abandon, " quests!")

	_update_dialogue()


func quest_done(report: Quest) -> void:
	report.queue_free()
	QUESTS_DONE += 1
	_update_dialogue()


func _update_dialogue() -> void:
	display_name.text = name
	population_label.text = "%s/%s" % [SIZE, POPULATION + len(UNITS)]
	_update_debug_info()


func _update_debug_info() -> void:
	debug_info.text = "Units(%s) Quests(%s/%s)" % [
			len(UNITS), len(QUESTS), QUESTS_DONE
		]
