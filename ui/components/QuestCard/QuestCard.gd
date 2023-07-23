extends Node

@export var type_label: Label
@export var rank_label: Label
@export var location_label: Label
@export var effort_label: Label
@export var reward_label: Label
@export var status_label: Label

var quest: Quest


func set_quest(data: Quest) -> void:
	quest = data
	update_data()


func update_data() -> void:
	type_label.text = Quest.type_name(quest.type)
	rank_label.text = Rank.name(quest.danger)
	location_label.text = quest.target.name
	effort_label.text = str(quest.length)
	reward_label.text = str(quest.reward)
	# status_label.text = quest.status
