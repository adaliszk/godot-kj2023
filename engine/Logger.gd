extends Node

enum LEVEL { VERBOSE, DEBUG, INFO, WARN, ERROR, FATAL }

@export var level: LEVEL = LEVEL.DEBUG
@export var messages: Array = []
@export var memory: int = 100

signal logged(message: String)


func _init() -> void:
	if not OS.is_debug_build():
		level = LEVEL.INFO


func info(message: String) -> void:
	if level <= LEVEL.INFO:
		_add_message(LEVEL.INFO, message)


func debug(message: String) -> void:
	if level <= LEVEL.DEBUG:
		_add_message(LEVEL.DEBUG, message)


func warn(message: String) -> void:
	if level <= LEVEL.WARN:
		_add_message(LEVEL.WARN, message)


func error(message: String) -> void:
	if level <= LEVEL.ERROR:
		_add_message(LEVEL.ERROR, message)


func fatal(message: String) -> void:
	if level <= LEVEL.FATAL:
		_add_message(LEVEL.FATAL, message)


func verbose(message: String) -> void:
	if level <= LEVEL.VERBOSE:
		_add_message(LEVEL.VERBOSE, message)


func _add_message(verbosity: LEVEL, message: String) -> void:
	if messages.size() > memory:
		messages.pop_front()

	var line = "%s:%s" % [LEVEL.keys().pop_at(verbosity)[0], message]
	messages.append(line)
	print(line)

	emit_signal("logged", line)
