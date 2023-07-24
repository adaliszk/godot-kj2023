extends Node

signal cycle_tick(state: int)
signal turn_tick(state: int)
signal night_tick(state: int)
signal day_tick(state: int)

enum SPEED { PAUSE, NORMAL, DOUBLE, TRIPLE }
const SPEED_VALUES = [INF, 2.0, 1.0, 0.5]

var _has_started = false
var _timer: Timer
var _cycle = -1
var _max_cycle = 8
var _turn = 0



func _ready() -> void:
	connect("cycle_tick", _on_cycle_tick.bind(self))
	connect("turn_tick", _on_turn_tick.bind(self))

	emit_signal("cycle_tick", _cycle + 1)
	emit_signal("turn_tick", _turn + 1)

	_timer = Timer.new()
	_timer.connect("timeout", tick.bind(self))
	set_speed(SPEED.NORMAL)
	add_child(_timer)


func set_speed(speed: SPEED) -> void:
	_timer.wait_time = SPEED_VALUES[speed]


func get_speed() -> String:
	var index = SPEED.values().find(_timer.wait_time)
	return SPEED.keys()[index]


func get_timeout() -> float:
	return _timer.wait_time


func start_ticks() -> void:
	_has_started = true
	_timer.start()


func stop_ticks() -> void:
	_timer.stop()


func reset_ticks() -> void:
	_cycle = 0
	_turn = 1


func has_started() -> bool:
	return _has_started


func tick(_event) -> void:
	emit_signal("cycle_tick", _cycle + 1)


func get_turn() -> int:
	return _turn


func get_cycle() -> int:
	return _cycle


func get_max_cycle() -> int:
	return _max_cycle


func _on_turn_tick(_state: int, _event) -> void:
	_turn = _turn + 1
	_cycle = 0


func _on_cycle_tick(_state: int, _event) -> void:
	_cycle = _state

	if _state > _max_cycle:
		emit_signal("turn_tick", _turn)

	if _state < 7:
		emit_signal("day_tick", _turn + _cycle)
		return

	emit_signal("night_tick", _turn + (_cycle - 7))
