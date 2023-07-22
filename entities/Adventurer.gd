class_name Adventurer
extends CharacterBody2D

@export var map: TileMap
@export var location: MapLocation
@export var rank: Rank.TIER

@onready var navigation: NavigationAgent2D = $NavigationAgent
@onready var state_display: Label = $Control/Bubble/Data/State

@export var total_quests: int = 0
var current_quest: Quest

var can_move: bool = false
var next_route: Vector2

@export var work_length: int = 0
@export var work_state: int = 0


func _init():
	var rng = RandomNumberGenerator.new()
	rank = 6 - rng.randi_range(0, 2) as Rank.TIER
	print("Adventurer with ", rank, " rank joined!")
	show()


func set_map_location(map: TileMap, poi: MapLocation) -> void:
	location = poi


func _on_tick() -> void:
	_update_state()
	if current_quest == null:
		pick_quest()
		return
	advance_quest()


func _update_state() -> void:
	state_display.text = "zZz"
	if current_quest:
		state_display.text = "%s (%s/%s)" % [
			Quest.STATUS.keys()[current_quest.state], current_quest.length, work_state
		]


func _physics_process(_delta):
	if not (current_quest is Quest): return
	velocity = Vector2.ZERO
	
	if can_move and not navigation.is_target_reached():
		next_route = to_local(navigation.get_next_path_position()).normalized()
		velocity = next_route * 500 
		move_and_slide()

	

func pick_quest() -> void:
	if not (location is Town): return
	if current_quest is Quest: return
	
	var available = location.QUESTS.filter(func(q): return q.danger <= rank -1 )
	print("Picking quests in ", location.name, " for a rank-", rank, " adventurer from: ", available)
	if len(available) == 0: return
	
	current_quest = available.pick_random()
	var board_index = location.QUESTS.find(current_quest)
	location.QUESTS.remove_at(board_index)


func advance_quest() -> void:
	if not (current_quest is Quest): return
	
	if navigation.is_target_reached():
		current_quest.set_state(Quest.STATUS.PROGRESSING)

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
			
		location = current_quest.target
		work_state = work_state + 1
		return
	
	can_move = true
	location = null
	show()


func plan_route(target: MapLocation) -> void:
	navigation.target_position = target.global_position
