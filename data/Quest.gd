class_name Quest
extends Node

enum STATUS { WAITING, ON_ROUTE, PROGRESSING, SUCCESS, FAILURE, DONE }


@export var issuer: MapLocation
@export var target: MapLocation
@export var length: int = 1
@export var reward: float = 1
@export var danger: Rank.TIER = Rank.TIER.F
@export var state: STATUS = STATUS.WAITING


func _init(_issuer: MapLocation, _target: MapLocation, min_danger: int, max_danger: int) -> void:
	var rng = RandomNumberGenerator.new()
	danger = rng.randi_range(min_danger, max_danger) as Rank.TIER
	var danger_multiplier = Rank.TIER_MULTIPLIER[danger]
	length = roundi(rng.randi_range(1, 12) * danger_multiplier) + 1
	reward = rng.randf_range(0.1, 5) * length * danger
	target = _target
	issuer = _issuer
	print("%s-Rank quest generated" % Rank.name(danger))


func set_state(new: STATUS) -> void:
	state = new
