class_name QuestBoard
extends Node

signal quest_recieved(quest: Quest)
signal quest_rejected(quest: Quest)
signal quest_accepted(quest: Quest, unit: Unit)
signal quest_completed(quest: Quest, earned: int)
signal quest_failed(quest: Quest)

@export var settlement: Settlement

@export var max_difficulty: Rank.TIER = Rank.TIER.E

@export var guild_cut: float = 0.2

@export var max_capacity: int = 24
@export var capacity: int:
	get:
		return quests.size()

var units: Array:
	get:
		return get_children()

var quests: Array = []
var quests_recieved: int = 0
var quests_rejected: int = 0
var quests_accepted: int = 0
var quests_completed: int = 0
var quests_suceeded: int = 0
var quests_failed: int = 0


func _ready():
	settlement = get_parent() if get_parent() is Settlement else null


func _enter_tree():
	settlement = get_parent() if get_parent() is Settlement else null
	if Engine.is_editor_hint():
		update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	if not settlement is Settlement:
		return ["Quest Boards needs to be a child of a `Settlement` to work properly."]
	return []


func add_quest(quest: Quest) -> void:
	emit_signal("quest_recieved", quest)
	quests_recieved += 1

	if quest.rank > max_difficulty:
		Log.warn("Quest is too difficult, cannot accept it!")
		emit_signal("quest_rejected", quest)
		quest.reject()
		return

	if quests.size() >= max_capacity:
		Log.warn("Quest board is full, cannot accept new quests!")
		emit_signal("quest_rejected", quest)
		quest.reject()
		return

	quests.append(quest)
	quest.recieve(self)


func accept_quest(quest: Quest, unit: Unit) -> void:
	emit_signal("quest_accepted", quest, unit)
	quests_accepted += 1


func collect_quest(quest: Quest) -> int:
	var result = quest.status
	if result == Quest.Status.SUCCESS:
		quests_suceeded += 1
	else:
		emit_signal("quest_failed", quest)
		quests_failed += 1

	var reward = round(quest.reward * (1 - guild_cut))
	var taxed = (quest.reward - reward) if result == Quest.Status.SUCCESS else -reward

	emit_signal("quest_completed", quest, taxed)
	quests_completed += 1

	quests.erase(quest)
	quest.complete()
	return reward if result == Quest.Status.SUCCESS else 0


func reject_quest(quest: Quest) -> void:
	emit_signal("quest_failed", quest)
	quests_rejected += 1

	quests.erase(quest)
	quest.fail()


func get_candidates(rank: Rank.TIER) -> Array:
	var candidates: Array = []
	for candidate in quests:
		if (
			(candidate.rank == rank or candidate.rank == rank + 1)
			and candidate.status <= Quest.Status.RECIEVED
		):
			candidates.append(candidate)
	candidates.sort_custom(func(a, b): return a.reward > b.reward)
	return candidates


func rank_up(unit: Unit) -> void:
	max_difficulty = unit.rank + 1 as Rank.TIER
