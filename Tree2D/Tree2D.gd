extends Node2D

# some L-systems:
# http://paulbourke.net/fractals/lsys/

# must be an AALSystem
export(Resource) var l_system

export(int) var start_length = 20
export(float) var length_factor = .5
export(int) var thickness = 1

export(int) var min_rotation = 15
export(float) var max_rotation = 35

export(Color) var colour = Color(1, 1, 1, 1)

var branches: Array

func _ready() -> void:
	randomize()
	generate()

func generate() -> void:
	assert(l_system is AALSystem, "l_system must be a resource of type AALSystem")
	
	var turtle: Turtle2D = Turtle2D.new()
	var sentence: String = l_system.generate()
	
	var length: float = start_length
	branches = []
	
	for character in sentence:
		if character == 'F':
			branches.append(turtle.create_line(length))
		elif character == '+':
			turtle.rotate(rand_range(min_rotation, max_rotation))
		elif character == '-':
			turtle.rotate(-rand_range(min_rotation, max_rotation))
		elif character == '[':
			turtle.push()
			length *= length_factor
		elif character == ']':
			turtle.pop()
			length /= length_factor

func _draw() -> void:
	for branch in branches:
		draw_line(branch.point1, branch.point2, colour, thickness)
