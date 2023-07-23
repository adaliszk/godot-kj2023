class_name Quest
extends Node

enum STATUS { WAITING, ON_ROUTE, PROGRESSING, SUCCESS, FAILURE, DONE }
enum TYPE { HUNTING, COLLECTION, EXPLORATION, GUARDING }


@export var type: TYPE = TYPE.EXPLORATION
@export var issuer: MapLocation
@export var target: MapLocation
@export var length: int = 1
@export var reward: float = 1
@export var danger: Rank.TIER = Rank.TIER.F
@export var state: STATUS = STATUS.WAITING


static func type_name(variant: TYPE) -> String:
	return TYPE.keys()[variant]


func _init(_issuer: MapLocation, _target: MapLocation) -> void:
	var rng = RandomNumberGenerator.new()

	type = TYPE.values()[rng.randi_range(0, TYPE.size() - 1)]
	length = roundi(rng.randi_range(1, 12) * Rank.multiplier(danger)) + 1
	reward = rng.randf_range(0.1, 5) * length * danger

	target = _target
	issuer = _issuer

	name = UUID.v4()

	Log.info("Quest.new(): %s-Rank Quest(%s) has been posted!" % [ Rank.name(danger), self.name])


func set_state(new: STATUS) -> void:
	state = new
