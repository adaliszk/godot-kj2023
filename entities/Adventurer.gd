class_name Adventurer
extends Unit

@export var map: TileMap
@export var location: MapLocation
@export var rank: Rank.TIER

@onready var navigation: NavigationAgent2D = $NavigationAgent

@onready var state_display: Label = $Dialogue/State
@onready var level_display: Label = $Dialogue/Level

var current_quest: Quest
@export var total_quests: int = 0

@export var rankup_limit: int = 100
@export var rank_quests: int = 0

@export var max_enery: int = 20
@export var energy: int = 1

@export var can_move: bool = false
@export var movement_speed: float = 200
@export var next_route: Vector2

@export var work_length: int = 0
@export var work_state: int = 0

@export var night_owl: bool = false


func _ready() -> void:
	GameTick.connect("night_tick", _on_night_tick.bind(self))
	GameTick.connect("day_tick", _on_day_tick.bind(self))


func _init():
	var rng := RandomNumberGenerator.new()
	rank = rng.randi_range(0, 2) as Rank.TIER
	night_owl = rng.randi_range(0, 1) == 1
	Log.info("Adventurer::new(): %s rank joined!" % Rank.name(rank))
	_update_stats()
	hide()


func set_map_location(poi: MapLocation) -> void:
	location = poi


func _on_night_tick(_state: int, _event) -> void:
	can_move = false if not night_owl else true
	_update_stats()
	_update_state()


func _on_day_tick(_state: int, _event) -> void:
	_update_state()

	if current_quest == null:
		pick_quest()
		return

	advance_quest()


func _update_state() -> void:
	level_display.text = (
		"%s-Rank Q(%s/%s) E(%s/%s)"
		% [
			Rank.name(rank),
			rankup_limit,
			rank_quests,
			max_enery,
			energy
		]
	)

	state_display.text = "zZz"
	if current_quest is Quest:
		state_display.text = (
			"[%s] %s (%s/%s)"
			% [
				Rank.name(current_quest.danger),
				Quest.STATUS.keys()[current_quest.state],
				current_quest.length,
				work_state
			]
		)


func _update_stats() -> void:
	var multiplier = Rank.multiplier(rank)

	max_enery = ceili(10 * multiplier)
	rankup_limit = ceili(100 * multiplier)

	if rank_quests >= rankup_limit:
		rank = rank - 1 as Rank.TIER
		rank_quests = 0
		print("Adventurer with ", Rank.name(rank), " rank advanced!")
		_update_stats()

	if energy <= max_enery and not can_move:
		energy = energy + 1


func _physics_process(_delta):
	if not (current_quest is Quest):
		return

	velocity = Vector2.ZERO
	if can_move and not navigation.is_target_reached():
		next_route = to_local(navigation.get_next_path_position()).normalized()
		var game_speed: float = GameTick.get_timeout()
		game_speed = 0.0 if game_speed == INF else (1/game_speed)
		velocity = next_route * (movement_speed * game_speed)
		move_and_slide()


func pick_quest() -> void:
	if not (location is Town) or current_quest is Quest:
		return

	var available = location.QUESTS.filter(
		func(q): return q.danger <= rank and q.danger >= rank - 2
	)

	available.sort_custom(
		func(a, b): return a.reward > b.reward
	)

	if len(available) == 0:
		return
	
	var quest_candidate = available.pop_front()
	while len(available) > 0:
		if quest_candidate.length > max_enery:
			break
		quest_candidate = available.pop_front()

	var board_index = location.QUESTS.find(quest_candidate)
	location.QUESTS.remove_at(board_index)
	current_quest = quest_candidate


func advance_quest() -> void:
	can_move = false
	if not (current_quest is Quest) or energy <= 0:
		energy = energy + 1
		return

	if navigation.is_target_reached():
		if current_quest.state == Quest.STATUS.SUCCESS:
			total_quests = total_quests + 1
			rank_quests = rank_quests + 1
			location = current_quest.issuer
			location.quest_done(current_quest)
			current_quest = null
			work_state = 0
			hide()
			return

		if current_quest.state == Quest.STATUS.ON_ROUTE:
			current_quest.set_state(Quest.STATUS.PROGRESSING)
			show()
			return

	if current_quest.state == Quest.STATUS.WAITING:
		work_length = current_quest.length
		current_quest.set_state(Quest.STATUS.ON_ROUTE)
		plan_route(current_quest.target)
		show()
		return

	if current_quest.state == Quest.STATUS.PROGRESSING:
		if work_state >= work_length:
			current_quest.set_state(Quest.STATUS.SUCCESS)
			plan_route(current_quest.issuer)
			show()
			return

		if energy <= 0:
			current_quest.set_state(Quest.STATUS.FAILURE)
			plan_route(current_quest.issuer)
			show()
			return

		location = current_quest.target
		work_state = work_state + 1
		energy = energy - 1
		return

	can_move = true
	location = null
	show()


func plan_route(target: MapLocation) -> void:
	navigation.target_position = target.global_position
