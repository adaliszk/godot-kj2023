extends Node

signal cycle_tick(state: int, cycle_type: CycleType)
signal turn_tick(state: int)

enum CycleType { MORNING, DAY, EVENING, NIGHT }
enum TurnSpeed { PAUSE, NORMAL, DOUBLE, TRIPLE, ULTRA }

const SPEED_VALUES = [INF, 2.0, 1.0, 0.5, 0.01]

const CYCLE_PER_TURN = 6
const CYCLE_TYPE_ASSIGMENT = [
	CycleType.MORNING,
	CycleType.DAY,
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
		Log.info("GameTick: Setting speed to %s" % value)
		_timer.stop()
		_timer.wait_time = SPEED_VALUES[value]
		_timer.start()
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
	Log.debug("GameTick.start()")
	_has_started = true
	_timer.start()


func stop() -> void:
	Log.debug("GameTick.stop()")
	_timer.stop()


func reset() -> void:
	Log.debug("GameTick.reset()")
	_cycle = 0
	_turn = 1

func cycle_type(current_cycle: int) -> String:
	var index = CYCLE_TYPE_ASSIGMENT[current_cycle]
	return CycleType.keys()[index]


# endregion

# region: Internal Logic


func _on_timer_tick(_event) -> void:
	Log.verbose("GameTick::on_timer_tick()")
	var new_cycle = cycle + 1
	if new_cycle > CYCLE_PER_TURN:
		emit_signal("turn_tick", _turn + 1)
		new_cycle = 0

	var type = CYCLE_TYPE_ASSIGMENT[new_cycle]
	emit_signal("cycle_tick", new_cycle, type)
	_cycle = new_cycle


func _on_turn_tick(new_turn: int, _event) -> void:
	_turn = new_turn
	_cycle = 0

# endregion
