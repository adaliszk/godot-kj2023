class_name Quest
extends Node

signal recieved
signal accepted
signal updated
signal concluded
signal completed

enum Status { UNKNOWN, RECIEVED, ACCEPTED, IN_PROGRESS, SUCCESS, FAILURE }
enum Type { UNKNOWN, EXPLORATION, HUNTING, COLLECTION }

const REQUIRED = ["rank", "handler", "location", "effort", "reward"]

var status: Status = Status.UNKNOWN

var type: Type:
	# TODO: Upgrade once https://github.com/godotengine/godot-proposals/issues/820 is available
	set(value):
		type = value if rank == Type.UNKNOWN else type
	get:
		return type

var rank: Rank.TIER:
	# TODO: Upgrade once https://github.com/godotengine/godot-proposals/issues/820 is available
	set(value):
		rank = value if rank == Rank.TIER.UNKNOWN else rank
	get:
		return rank

var difficulty: Rank.TIER:
	# TODO: Upgrade once https://github.com/godotengine/godot-proposals/issues/820 is available
	set(value):
		difficulty = value if difficulty == Rank.TIER.UNKNOWN else difficulty
	get:
		return difficulty

var handler: QuestBoard:
	# TODO: Upgrade once https://github.com/godotengine/godot-proposals/issues/820 is available
	set(value):
		handler = value if handler == null else handler
	get:
		return handler

var unit: Unit:
	set(value):
		unit = value
	get:
		return unit

var location: QuestSpawner:
	# TODO: Upgrade once https://github.com/godotengine/godot-proposals/issues/820 is available
	set(value):
		location = value if location == null else location
	get:
		return location

var deadline: int = 0
var progress: int = 0
var effort: int:
	# TODO: Upgrade once https://github.com/godotengine/godot-proposals/issues/820 is available
	set(value):
		effort = value if effort == 0 else effort
	get:
		return effort

var reward_supplement: int = 0
var reward: int:
	# TODO: Upgrade once https://github.com/godotengine/godot-proposals/issues/820 is available
	set(value):
		reward = value if reward == 0 else reward
	get:
		return reward + reward_supplement

var success_roll: float = 0.0
var success_chance: float = 0.5:
	get:
		return (
			(Rank.multiplier(unit.rank) * Rank.probablity(difficulty))
			+ ((unit.experience * Rank.multiplier(difficulty)) / 2)
		)


static func status_name(id: Status) -> String:
	return Status.keys()[id]


func _init(data: Dictionary) -> void:
	# Check and Set required fields
	for field in REQUIRED:
		if not field in data:
			Log.error("ERROR: You must specify '%s' field when creating a quest." % field)
		else:
			self[field] = data[field]
			data.erase(field)

	# Set optional fields
	for field in data:
		if field in self:
			self[field] = data[field]

	# Calculate unset fields
	var min_difficulty = rank - 1
	var max_difficulty = rank + 1

	if difficulty == Rank.TIER.UNKNOWN and location is QuestSpawner:
		min_difficulty = location.zone_difficulty - 1
		max_difficulty = location.zone_difficulty + 1

	var max_deadline = (10 * ceili(Rank.multiplier(difficulty))) + 3
	deadline = randi_range(3, max_deadline)

	# TODO: Use clamp for this
	difficulty = (
		randi_range(
			min_difficulty if min_difficulty > Rank.TIER.UNKNOWN else Rank.TIER.F,
			max_difficulty if max_difficulty <= Rank.TIER.SS else Rank.TIER.SS
		)
		as Rank.TIER
	)

	# Fixed fields
	name = UUID.v4()

func _ready() -> void:
	GameTick.connect("turn_tick", _on_turn_tick.bind(self))


func _on_turn_tick(_turn: int, _event) -> void:
	if status <= Status.RECIEVED:
		deadline -= 1
		if deadline <= 0:
			reject()


func is_completed() -> bool:
	return status == Status.SUCCESS or status == Status.FAILURE


func recieve(_board: QuestBoard) -> void:
	status = Status.RECIEVED
	emit_signal("recieved")


func accept(assignee: Unit) -> Quest:
	if status >= Status.ACCEPTED:
		Log.error("ERROR: Quest '%s' has already been accepted." % name)
		return null

	status = Status.ACCEPTED
	unit = assignee
	emit_signal("accepted")

	return self


func advance() -> void:
	status = Status.IN_PROGRESS
	self.progress += 1
	emit_signal("updated")

	if self.progress == self.effort:
		self.finish()


func finish() -> void:
	success_roll = success_chance >= randf_range(0.0, 1.0)
	var msg = (
		"%s-Rank quest(#%s) finished with %s (chance:%s,diff:%s)"
		% [
			Rank.name(rank),
			UUID.short(name),
			"SUCCESS" if success_roll else "FAILURE",
			success_chance,
			Rank.name(difficulty),
		]
	)
	Log.debug(msg)
	status = Status.SUCCESS if success_roll else Status.FAILURE
	emit_signal("concluded")


func complete() -> void:
	location.complete_quest(self)
	emit_signal("completed")


func reject() -> void:
	if handler is QuestBoard:
		handler.reject_quest(self)


func fail() -> void:
	status = Status.FAILURE
	emit_signal("completed")
