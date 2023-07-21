extends Node

signal cycle_tick(state: int)
signal turn_tick(state: int)
signal night_tick(state: int)
signal day_tick(state: int)


var _TIMER : Timer
var _CYCLE_TIME = 12.0
var _CYCLE = 0
var _MAX_CYCLE = 8
var _TURN = 1


func _ready() -> void:
	connect("cycle_tick", _on_cycle_tick.bind(self))
	connect("turn_tick", _on_turn_tick.bind(self))
	
	_TIMER = Timer.new()
	_TIMER.wait_time = _CYCLE_TIME
	_TIMER.connect("timeout", tick.bind(self))
	add_child(_TIMER)


func start_ticks() -> void:
	_TIMER.start()


func stop_ticks() -> void:
	_TIMER.stop()


func reset_ticks() -> void:
	_CYCLE = 0
	_TURN = 1


func tick(_event) -> void:
	emit_signal("cycle_tick", _CYCLE +1)


func get_turn() -> int:
	return _TURN


func get_cycle() -> int:
	return _CYCLE


func get_max_cycle() -> int:
	return _MAX_CYCLE


func _on_turn_tick(_state: int, _event) -> void:
	_TURN = _TURN + 1
	_CYCLE = 0


func _on_cycle_tick(_state: int, _event) -> void:
	_CYCLE = _state

	if _state > _MAX_CYCLE:
		emit_signal("turn_tick", _TURN)
	
	if _state < 6:
		emit_signal("day_tick", _TURN + _state)
		return
	
	emit_signal("night_tick", _TURN + (_state - 6))
