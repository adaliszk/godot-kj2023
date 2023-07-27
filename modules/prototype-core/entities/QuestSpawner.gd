@tool
class_name QuestSpawner
extends Node

signal quest_raised(quest: Quest)
signal quest_submitted(quest: Quest)
signal quest_completed(quest: Quest, unit: Unit)
signal quest_failed(quest: Quest, unit: Unit)

@export var quest_board: QuestBoard

@export var quest_rank: Rank.TIER = Rank.TIER.F
@export var quest_probablity: float = 0.5
@export var quest_min_reward: int = 50
@export var quest_max_reward: int = 100
@export var quest_min_count: int = 1
@export var quest_max_count: int = 1
@export var quest_min_effort: int = 1
@export var quest_max_effort: int = 3

@export var zone_difficulty: Rank.TIER = Rank.TIER.F

@export var monsters_max_count: int = 20
@export var monsters_current_count: int = 5
@export var monsters_spawn_rate: float = 0.25

@export var resource_available: int = 100
@export var resource_spawn_rate: int = 5


func _ready() -> void:
	GameTick.connect("turn_tick", _on_tick.bind(self))
	generate_quest(randi_range(quest_min_count, quest_max_count))


func _on_tick(_tick: int, _event) -> void:
	Log.verbose("%s::on_tick()" % name)
	if quest_probablity >= randf_range(0, 1):
		generate_quest(randi_range(quest_min_count, quest_max_count))


func generate_quest(amount: int) -> void:
	for i in range(amount):
		var quest_data = {
			rank = quest_rank,
			reward = randi_range(quest_min_reward, quest_max_reward),
			effort = randi_range(quest_min_effort, quest_max_effort),
			handler = quest_board,
			location = self,
		}
		var quest = Quest.new(quest_data)
		var msg = (
			"New %s-Rank quest is available in %s for %s coin!"
			% [
				Rank.name(quest.rank),
				get_parent().name,
				quest.reward,
			]
		)
		Log.info(msg)

		if quest_board:
			quest_board.add_quest(quest)
			emit_signal("quest_submitted", quest)
		else:
			emit_signal("quest_raised", quest)

		add_child(quest)


func accept_quest(quest: Quest, unit: Unit) -> void:
	emit_signal("quest_accepted", quest, unit)
	quest_board.accept_quest(quest, unit)
	add_child(quest)


func complete_quest(quest: Quest) -> void:
	emit_signal("quest_completed", quest)
	remove_child(quest)


func fail_quest(quest: Quest) -> void:
	emit_signal("quest_failed", quest)
	remove_child(quest)
