class_name Quest
extends Node

enum STATUS { WAITING, ON_ROUTE, PROGRESSING, SUCCESS, FAILURE, DONE }


@export var issuer: MapLocation
@export var target: MapLocation
@export var length: int = 1
@export var reward: int = 1
@export var danger: Rank.TIER = Rank.TIER.F
@export var state: STATUS = STATUS.WAITING


func _init(_issuer: MapLocation, _target: MapLocation) -> void:
	var rng = RandomNumberGenerator.new()
	danger = rng.randi_range(3, 6) as Rank.TIER
	length = roundi(rng.randi_range(1, 12) * danger)
	reward = rng.randf_range(0.1, 5) * length * danger
	target = _target
	issuer = _issuer


func set_state(new: STATUS) -> void:
	state = new
