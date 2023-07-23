class_name QuestBoard
extends Container

# Event signals
signal quest_recieved(quest: Quest)
signal quest_accepted(quest: Quest)
signal quest_completed(quest: Quest)
signal quest_revoked(quest: Quest)
signal board_updated

# Autowring using the node tree
@onready var availablePOIs: Container = get_parent().get_parent()
@onready var settlement: Town = get_parent()

# Properties with defaults
@export var minDanger: Rank.TIER = Rank.TIER.F
@export var maxDanger: Rank.TIER = Rank.TIER.D
@export var minReward: int = 100
@export var maxReward: int = 1000
@export var minQuests: int = 6
@export var maxQuests: int = 24
@export var minQuestLength: int = 1
@export var maxQuestLength: int = 12

# Public states
@export var quests: Array = []
@export var questsDelivered: int = 0
@export var questsFailed: int = 0

# Calculated states
@export var questsCompleted: int:
	get: return questsDelivered + questsFailed


func _ready() -> void:
	settlement.connect("unit_spawned", _on_unit_spawned.bind(self))
	GameTick.connect("turn_tick", _on_game_tick.bind(self))
	Log.info("QuestManager::ready()")


func _on_game_tick(_cycle: int, _event) -> void:
	Log.debug("QuestManager::on_game_tick()")
	var rng = RandomNumberGenerator.new()

	if quests.size() < minQuests:
		generate(rng.randi_range(0, minQuests))


func _on_unit_spawned(unit: Adventurer, _event) -> void:
	Log.debug("QuestManager::on_unit_spawned()")
	if unit.rank > maxDanger:
		Log.info("QuestBoard:on_unit_spawned(): Possible quest difficulty raised to %s!" % Rank.name(unit.rank))
		maxDanger = unit.rank


func generate(amount: int = 1) -> void:
	Log.debug("QuestManager::generate(%s)" % amount)
	var rng = RandomNumberGenerator.new()

	for i in range(amount):
		# TODO(KISS,SRP): Make this into a utility function or find a better solution
		var poiList = []
		for poi in availablePOIs.get_children():
			poiList.append(poi)
		
		var target = poiList.pick_random()
		var quest = Quest.new(settlement, target)

		var danger = rng.randi_range(minDanger, maxDanger)
		var dangerMultiplier = Rank.multiplier(danger)

		quest.length = roundi(rng.randi_range(minQuestLength, maxQuestLength) * dangerMultiplier) + 1
		quest.reward = round(rng.randf_range(minReward, maxReward) * dangerMultiplier)
		quest.danger = danger

		quests.append(quest)
		emit_signal("quest_recieved", quest)
	emit_signal("board_updated")


func accept(quest: Quest) -> void:
	Log.debug("QuestManager::accept(%s)" % quest.name)
	emit_signal("quest_accepted", quest)
	emit_signal("board_updated")


func complete(quest: Quest) -> void:
	Log.debug("QuestManager::complete(%s)" % quest.name)
	emit_signal("quest_completed", quest)
	emit_signal("board_updated")


func revoke(quest: Quest) -> void:
	Log.debug("QuestManager::complete(%s)" % quest.name)
	emit_signal("quest_revoked", quest)
	emit_signal("board_updated")
