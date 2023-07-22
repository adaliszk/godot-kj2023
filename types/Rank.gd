class_name Rank

const TIER_MULTIPLIER = [4.0, 2.0, 1.0, 0.75, 0.5, 0.25, 0.1]
enum TIER { S, A, B, C, D, E, F }


static func name(tier: TIER) -> String:
    return TIER.keys()[tier]