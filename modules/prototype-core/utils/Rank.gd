class_name Rank
extends Object

enum TIER { UNKNOWN, F, E, D, C, B, A, S, SS }
const MULTIPLIER = [0, 0.1, 0.25, 0.5, 1.0, 2.0, 3.0, 6.0, 12.0]


static func multiplier(tier: TIER) -> float:
	return MULTIPLIER[tier]


static func probablity(tier: TIER) -> float:
	if tier == TIER.UNKNOWN:
		return 0
	return 1 / MULTIPLIER[tier]


static func name(tier: TIER) -> String:
	return TIER.keys()[tier]
