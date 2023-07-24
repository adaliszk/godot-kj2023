class_name QuestBoard
extends Container

# Event signals
signal quest_recieved(quest: Quest)
signal quest_accepted(quest: Quest)
signal quest_completed(quest: Quest)
signal quest_revoked(quest: Quest)
signal board_updated

# Properties with defaults
@export var min_danger: Rank.TIER = Rank.TIER.F
@export var max_danger: Rank.TIER = Rank.TIER.D
@export var min_reward: int = 100
@export var max_reward: int = 1000
@export var min_quests: int = 6
@export var max_quests: int = 24
@export var min_quest_length: int = 1
@export var max_quest_length: int = 12

# Public states
@export var quests: Array = []
@export var quests_active: int = 0
@export var quests_delivered: int = 0
@export var quests_failed: int = 0

# Calculated states
@export var quests_completed: int:
	get:
		return quests_delivered + quests_failed

# Autowring using the node tree
@onready var available_locations: Container = get_parent().get_parent()
@onready var settlement: Town = get_parent()


func _ready() -> void:
	settlement.connect("unit_spawned", _on_unit_spawned.bind(self))
	GameTick.connect("turn_tick", _on_game_tick.bind(self))
	Log.info("QuestManager::ready()")


func _on_game_tick(_cycle: int, _event) -> void:
	Log.debug("QuestManager::on_game_tick()")
	var rng = RandomNumberGenerator.new()

	if quests.size() < min_quests:
		generate(rng.randi_range(0, min_quests))


func _on_unit_spawned(unit: Adventurer, _event) -> void:
	Log.debug("QuestManager::on_unit_spawned()")
	if unit.rank > max_danger:
		Log.info(
			(
				"QuestBoard:on_unit_spawned(): Possible quest difficulty raised to %s!"
				% Rank.name(unit.rank)
			)
		)
		max_danger = unit.rank


func generate(amount: int = 1) -> void:
	Log.debug("QuestManager::generate(%s)" % amount)
	var rng = RandomNumberGenerator.new()

	for i in range(amount):
		# TODO(KISS,SRP): Make this into a utility function or find a better solution
		var locations_list = []
		for poi in available_locations.get_children():
			locations_list.append(poi)

		var target = locations_list.pick_random()
		var quest = Quest.new(settlement, target)

		var danger = rng.randi_range(min_danger, max_danger)
		var danger_multiplier = Rank.multiplier(danger)

		quest.length = (
			roundi(rng.randi_range(min_quest_length, max_quest_length) * danger_multiplier) + 1
		)
		quest.reward = round(rng.randf_range(min_reward, max_reward) * danger_multiplier)
		quest.danger = danger

		quests.append(quest)
		emit_signal("quest_recieved", quest)
	emit_signal("board_updated")


func accept(quest: Quest) -> void:
	Log.debug("QuestManager::accept(%s)" % quest.name)
	quests_active += 1
	emit_signal("quest_accepted", quest)
	emit_signal("board_updated")


func complete(quest: Quest) -> void:
	Log.debug("QuestManager::complete(%s)" % quest.name)
	quests_completed += 1
	quests_active -= 1
	emit_signal("quest_completed", quest)
	emit_signal("board_updated")


func revoke(quest: Quest) -> void:
	Log.debug("QuestManager::complete(%s)" % quest.name)
	quests_failed += 1
	emit_signal("quest_revoked", quest)
	emit_signal("board_updated")
