class_name Rank

enum TIER { F, E, D, C, B, A, S }
const MULTIPLIER = [0.1, 0.25, 0.5, 1.0, 2.0, 3.0, 6.0]


static func multiplier(tier: TIER) -> float:
	return MULTIPLIER[tier]


static func probablity(tier: TIER) -> float:
	return 1 / MULTIPLIER[tier]


static func name(tier: TIER) -> String:
	return TIER.keys()[tier]
