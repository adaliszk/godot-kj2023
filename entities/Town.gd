class_name Town
extends LocationWithDialogue

signal population_changed
signal unit_spawned(unit: Node)

@export var debug_info: RichTextLabel
@export var population_label: Label
@export var display_name: Label

@export var max_population: int = 20
@export var current_population: int = 0


func _ready() -> void:
	for i in range(3):
		spawn_unit()


func update_popover():
	population_label.text = "%s/%s" % [max_population, current_population]
	display_name.text = name


func spawn_unit() -> void:
	var new_unit = (preload("res://entities/Adventurer.tscn")).instantiate()
	new_unit.position = position
	get_parent().find_child(name).add_child(new_unit)
	current_population += 1
	update_popover()

	emit_signal("unit_spawned", new_unit)
	emit_signal("population_changed")


func _on_turn_tick(_state: int, _event) -> void:
	var rng = RandomNumberGenerator.new()
	if rng.randf() < 0.1:
		spawn_unit()
