extends Node

@export var quest_board: QuestBoard
@export var settlement: Settlement

@export var turn_state: Label
@export var money_state: Label
@export var quest_state: Label
@export var unit_state: Label

@export var quest_list: RichTextLabel
@export var unit_list: RichTextLabel

var session: GameSession


func _ready() -> void:
	GameTick.connect("cycle_tick", _on_cycle_tick.bind(self))
	GameTick.speed = GameTick.TurnSpeed.ULTRA
	GameTick.start()

	session = GameSession.new()
	session.quest_board = quest_board
	session.settlement = settlement
	add_child(session)


func _unhandled_key_input(event) -> void:
	if event.is_action_pressed("game_pause"):
		GameTick.speed = GameTick.TurnSpeed.PAUSE
	if event.is_action_pressed("game_speed_normal"):
		GameTick.speed = GameTick.TurnSpeed.NORMAL
	if event.is_action_pressed("game_speed_double"):
		GameTick.speed = GameTick.TurnSpeed.DOUBLE
	if event.is_action_pressed("game_speed_triple"):
		GameTick.speed = GameTick.TurnSpeed.TRIPLE
	if event.is_action_pressed("game_speed_ultra"):
		GameTick.speed = GameTick.TurnSpeed.ULTRA


func _on_cycle_tick(_cycle: int, _type: GameTick.CycleType, _event) -> void:
	turn_state.text = (
		"Turn: %s (%s/%s) %s"
		% [
			GameTick.turn,
			GameTick.CYCLE_PER_TURN,
			GameTick.cycle,
			GameTick.cycle_type(GameTick.cycle)
		]
	)

	money_state.text = (
		"Money: ¤%s"
		% [
			session.money,
		]
	)

	quest_state.text = (
		"Quests: recieved:%s rejected:%s available:%s failed:%s completed:%s"
		% [
			quest_board.quests_recieved,
			quest_board.quests_rejected,
			quest_board.quests.size(),
			quest_board.quests_failed,
			quest_board.quests_completed,
		]
	)

	unit_state.text = (
		"Units: %s"
		% [
			settlement.units.size(),
		]
	)

	update_quest_list()
	update_unit_list()


func update_quest_list() -> void:
	quest_list.text = ""
	for quest in quest_board.quests:
		quest_list.text += (
			"#%s [%s] %s/%s (%s-rank at %s for %s coins) exp.:%s\n"
			% [
				UUID.short(quest.name),
				Quest.status_name(quest.status),
				quest.effort,
				quest.progress,
				Rank.name(quest.rank),
				quest.location.name,
				quest.reward,
				quest.deadline,
			]
		)


func update_unit_list() -> void:
	unit_list.text = ""
	for unit in settlement.units:
		unit_list.text += (
			"#%s (%s-rank with XP(%s/%s) E(%s) ¤(%s), doing %s)\n"
			% [
				UUID.short(unit.name),
				Rank.name(unit.rank),
				unit.max_experience,
				unit.experience,
				unit.energy,
				unit.money,
				"nothing" if unit.quest == null else "#%s" % UUID.short(unit.quest.name),
			]
		)
