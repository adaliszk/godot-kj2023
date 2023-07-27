extends GutTest

# TODO: Write an initialization check that verifies that the constructor throws assertion errors
# func test_quest_initialization() -> void:
#	autofree(Quest.new(params.data))

var lifecycle_scenarios = (
	ParameterFactory
	. named_parameters(
		["quest_rank", "unit_rank", "result"],
		[
			[
				# Rank.F with a Rank.F unit should be 100% success rate
				# -> 0.1 * 1/0.1 = 1.0
				Rank.TIER.F,
				Rank.TIER.F,
				Quest.Status.SUCCESS
			],
			[
				# Rank.S quest with Rank.F unit should be 1.6% success rate
				# -> 0.1 * 1/6.0 = 0.016
				Rank.TIER.S,
				Rank.TIER.F,
				Quest.Status.FAILURE
			]
		],
	)
)


func test_quest_lifecycle(params = use_parameters(lifecycle_scenarios)) -> void:
	var quest_data = {
		location = null,
		handler = null,
		rank = params.quest_rank,
		difficulty = params.quest_rank,
		effort = 3,
		reward = 1,
	}

	var unit_data = {
		rank = params.unit_rank,
	}

	var quest = autofree(Quest.new(quest_data))
	var unit = autofree(Unit.new(unit_data))
	watch_signals(quest)

	assert_eq(quest.status, Quest.Status.UNKNOWN)
	quest.accept(unit)

	assert_eq(quest.status, Quest.Status.ACCEPTED)
	assert_eq(quest.progress, 0)

	quest.advance()
	assert_signal_emit_count(quest, "updated", 1)
	assert_eq(quest.status, Quest.Status.IN_PROGRESS)
	assert_eq(quest.progress, 1)

	quest.advance()
	assert_signal_emit_count(quest, "updated", 2)
	assert_eq(quest.status, Quest.Status.IN_PROGRESS)
	assert_eq(quest.progress, 2)

	quest.advance()
	assert_signal_emit_count(quest, "updated", 3)
	assert_eq(quest.status, params.result)
	assert_eq(quest.progress, 3)

	assert_signal_emit_count(quest, "completed", 1)
