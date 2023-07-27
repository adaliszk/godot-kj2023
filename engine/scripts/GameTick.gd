extends Node

signal cycle_tick(state: int, cycle_type: CycleType)
signal turn_tick(state: int)

enum CycleType { MORNING, DAY, EVENING, NIGHT }
enum TurnSpeed { PAUSE, NORMAL, DOUBLE, TRIPLE }

const SPEED_VALUES = [INF, 2.0, 1.0, 0.5]

const CYCLE_PER_TURN = 6
const CYCLE_TYPE_ASSIGMENT = [
	CycleType.MORNING,
	CycleType.DAY,
	CycleType.DAY,
	CycleType.EVENING,
	CycleType.NIGHT,
	CycleType.NIGHT,
]

# region: Public API

var has_started: bool:
	get:
		return _has_started

var turn: int:
	get:
		return _turn

var speed: TurnSpeed:
	set(value):
		_timer.wait_time = SPEED_VALUES[value]
	get:
		var index = TurnSpeed.values().find(_timer.wait_time)
		return TurnSpeed.keys()[index]

var timeout: float:
	get:
		return _timer.wait_time

var cycle: int:
	get:
		return _cycle

# endregion

# region: Private State

var _timer: Timer
var _has_started = false
var _cycle = -1
var _turn = 0

# endregion

# region: Lifecycle Hooks


func _ready() -> void:
	connect("turn_tick", _on_turn_tick.bind(self))

	emit_signal("cycle_tick", _cycle + 1)
	emit_signal("turn_tick", _turn + 1)

	_timer = Timer.new()
	_timer.connect("timeout", _on_timer_tick.bind(self))
	speed = TurnSpeed.NORMAL
	add_child(_timer)


# endregion

# region: Public Methods


func start() -> void:
	_has_started = true
	_timer.start()


func stop() -> void:
	_timer.stop()


func reset() -> void:
	_cycle = 0
	_turn = 1


# endregion

# region: Internal Logic


func _on_timer_tick(_event) -> void:
	var new_cycle = cycle + 1
	var type = CYCLE_TYPE_ASSIGMENT[new_cycle]

	if cycle > CYCLE_PER_TURN:
		emit_signal("turn_tick", _turn + 1)

	emit_signal("cycle_tick", _cycle, type)


func _on_turn_tick(new_turn: int, _event) -> void:
	_turn = new_turn
	_cycle = 0

# endregion
