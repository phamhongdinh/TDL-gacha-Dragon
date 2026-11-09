class_name BannerDefinition
extends Resource

@export var id: String
@export var title: String
@export var featured_dragon_id: String
# Integer weights: 10 / 10000 = 0.1% per independent pull.
@export var weights: Dictionary = {}

func probability(dragon_id: String) -> float:
	var total := 0
	for weight in weights.values():
		total += int(weight)
	if total == 0:
		return 0.0
	return float(weights.get(dragon_id, 0)) / float(total)
