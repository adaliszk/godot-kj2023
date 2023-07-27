@tool
class_name Unit
extends CharacterBody2D

const REQUIRED = ["rank"]

@export var settlement: Settlement

@export var rank: Rank.TIER = Rank.TIER.F
@export var max_energy: int = 6
@export var energy: int = 6
@export var max_experience: int:
	get:
		return ceili(Rank.multiplier(rank) * 100)
@export var experience: float = 0.0
@export var money: int = 30

@export var quest_board: QuestBoard
@export var quest_desirability: float:
	get:
		var desired_savings = settlement.tavern.cost_per_turn * 14 as float
		return 1.0 if money < desired_savings else 1.0 - (desired_savings / money)

@export var quest: Quest


func _init(data: Dictionary = {}) -> void:
	# Check and Set required fields
	for field in REQUIRED:
		if not field in data and self[field] == null:
			Log.error("ERROR: You must specify '%s' field when creating a unit." % field)
		elif field in data:
			self[field] = data[field]
			data.erase(field)

	# Set optional fields
	for field in data:
		if field in self:
			self[field] = data[field]


func _ready():
	settlement = get_parent() if get_parent() is Settlement else null
	quest_board = settlement.quest_board if settlement else null
	GameTick.connect("cycle_tick", _on_cycle_tick.bind(self))
	GameTick.connect("turn_tick", _on_turn_tick.bind(self))
	# Fixed fields
	set_name.call_deferred(UUID.v4())
	# Automatically set grouping
	add_to_group("units")


func _enter_tree():
	if Engine.is_editor_hint():
		settlement = get_parent() if get_parent() is Settlement else null
		quest_board = settlement.quest_board if settlement else null
		update_configuration_warnings()
		# Automatically set grouping
		add_to_group("units")


func _get_configuration_warnings() -> PackedStringArray:
	if not settlement is Settlement:
		return ["Unit needs to be a child of a `Settlement` to work properly."]
	return []


func _on_cycle_tick(_cycle: int, type: GameTick.CycleType, _event):
	# TODO(PERF): Do this on a separate thread
	think(type)


func _on_turn_tick(_turn: int, _event):
	if quest == null:
		pay_bills()
	rank_up()


func pay_bills() -> void:
	money -= settlement.tavern.cost_per_turn
	if money < 0:
		queue_free()


func rank_up() -> void:
	if rank == Rank.TIER.S:
		return
	if experience >= max_experience:
		rank = (rank + 1) as Rank.TIER
		max_energy += ceili(2 * Rank.multiplier(rank))
		quest_board.rank_up(self)
		experience = 0.0


func think(type: GameTick.CycleType) -> void:
	if not type == GameTick.CycleType.NIGHT:
		take_rest()
		return

	if quest == null:
		pick_quest()
		return

	if quest.is_completed():
		complete_quest()
		return

	advance_quest()


func take_rest() -> void:
	if energy >= max_energy:
		return
	energy += 1


func pick_quest() -> void:
	if quest_board == null:
		return

	if quest_desirability <= randf_range(0.0, 1.00):
		return

	var candidates = quest_board.get_candidates(rank)
	if candidates.size() == 0:
		return
	var pick_index = randi_range(1, candidates.size()) - 1
	quest = candidates[pick_index].accept(self)


func navigate_to_quest() -> void:
	pass


func navigate_to_home() -> void:
	pass


func advance_quest() -> void:
	# TODO: Check for location, and if not at quest location, navigate to it
	quest.advance()
	energy -= 1


func complete_quest() -> void:
	if quest_board == null:
		return

	# TODO: Check for location, and if not at home location, navigate to it
	var reward = quest_board.collect_quest(quest)
	if experience < max_experience:
		var min_xp = Rank.multiplier(rank) * 6
		var max_xp = Rank.multiplier(rank) * 12
		experience += randi_range(min_xp, max_xp) as float

	money += quest.reward
	quest = null
