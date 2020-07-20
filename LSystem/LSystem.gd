tool
class_name LSystem
extends AACustomResource


# the starting string
export(String) var axiom
# each rule must be an AARule
export(Array, Resource) var rules
export(int, 1, 20) var num_generations = 5


func generate() -> String:
	assert(len(axiom) > 0, "axiom required")
	assert(len(rules) > 0, "at least one rule required")
	for rule in rules:
		assert(rule is Rule, "rules must be resource of type Rule")

	var sentence: String = axiom

	for i in (num_generations):
		var new_sentence := ""
		for character in sentence:
			var found := false
			for rule in rules:
				if rule.predecessor == character:
					new_sentence += rule.successor
					found = true
					break
			if not found:
				new_sentence += character

		sentence = new_sentence

	return sentence
