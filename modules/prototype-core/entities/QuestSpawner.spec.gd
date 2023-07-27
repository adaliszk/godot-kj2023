extends GutTest


func test_spawner_can_generate_quest() -> QuestSpawner:
	var spawner = autofree(QuestSpawner.new())
	watch_signals(spawner)

	spawner.generate_quest(1)

	assert_signal_emit_count(spawner, "quest_submitted", 1)
	assert_eq(spawner.get_child_count(), 1)

	return spawner


func test_spawner_can_complete_quests() -> void:
	var spawner = test_spawner_can_generate_quest()
	var quest = autofree(spawner.get_children()[0])
	spawner.complete_quest(quest)

	assert_signal_emit_count(spawner, "quest_completed", 1)
	assert_eq(spawner.get_child_count(), 0)


func test_spawner_can_fail_quests() -> void:
	var spawner = test_spawner_can_generate_quest()
	var quest = autofree(spawner.get_children()[0])
	spawner.fail_quest(quest)

	assert_signal_emit_count(spawner, "quest_failed", 1)
	assert_eq(spawner.get_child_count(), 0)
