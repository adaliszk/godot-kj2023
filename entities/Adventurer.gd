class_name Adventurer
extends Unit

@export var map: TileMap
@export var location: MapLocation
@export var rank: Rank.TIER
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

var current_quest: Quest

@onready var navigation: NavigationAgent2D = $NavigationAgent
@onready var state_display: Label = $Dialogue/State
@onready var level_display: Label = $Dialogue/Level


func _ready() -> void:
	GameTick.connect("night_tick", _on_night_tick.bind(self))
	GameTick.connect("day_tick", _on_day_tick.bind(self))


func _init():
	var rng := RandomNumberGenerator.new()
	rank = rng.randi_range(0, 2) as Rank.TIER
	Log.info("Adventurer::new(): %s rank joined!" % Rank.name(rank))
	_update_stats()
	hide()


func set_map_location(poi: MapLocation) -> void:
	location = poi


func _on_night_tick(_state: int, _event) -> void:
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
		% [Rank.name(rank), rankup_limit, rank_quests, max_enery, energy]
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
		game_speed = 0.0 if game_speed == INF else (1 / game_speed)
		velocity = next_route * (movement_speed * game_speed)
		move_and_slide()


func pick_quest() -> void:
	if not (location is Town) or current_quest is Quest:
		return

	var available = location.QUESTS.filter(
		func(q): return q.danger <= rank and q.danger >= rank - 2
	)

	available.sort_custom(func(a, b): return a.reward > b.reward)

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
	pass  # TODO


func plan_route(target: MapLocation) -> void:
	navigation.target_position = target.global_position
