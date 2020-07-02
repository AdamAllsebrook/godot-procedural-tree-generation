tool
extends Resource
class_name AALSystem

export(String) var axiom
export(Array, Resource) var rules
export(int, 1, 7) var num_generations = 5

func generate(print_results: bool = false) -> String:
	assert(len(axiom) > 0, "axiom required")
	assert(len(rules) > 0, "at least one rule required")
	for rule in rules:
		assert(rule is AARule, "rules must be resource of type AARule")

	if print_results:
		print(axiom)
	var sentence: String = axiom

	for i in (num_generations):
		var new_sentence := ""
		for character in sentence:
			var found := false
			for rule in rules:
				if rule.pre == character:
					new_sentence += rule.succ
					found = true
					break
			if not found:
				new_sentence += character

		sentence = new_sentence
		if print_results:
			print(sentence)

	return sentence
