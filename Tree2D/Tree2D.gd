extends Node2D

# some L-systems:
# http://paulbourke.net/fractals/lsys/

# alphabet:
# F: create branch and move forward
# +: rotate right
# -: rotate left
# [: push a new transformation onto the stack
# ]: pop a transformation from the stack 

# must be an LSystem
export(Resource) var l_system

export(int) var start_length = 20
export(float) var length_factor = .5
export(int, 1, 100) var thickness = 1

export(float, 0, 360) var min_rotation = 15
export(float, 0, 360) var max_rotation = 35

export(Color) var colour = Color(1, 1, 1, 1)

export(int) var random_seed = 0

var branches: Array


func _ready() -> void:
	generate()


func generate() -> void:
	assert(l_system is LSystem, "l_system must be a resource of type LSystem")
	seed(random_seed)
	
	var turtle: Turtle2D = Turtle2D.new()
	var sentence: String = l_system.generate()
	
	var length: float = start_length
	branches = []
	
	for character in sentence:
		match character:
			'F':
				branches.append(turtle.create_line(length))
			'+':
				turtle.rotate(rand_range(min_rotation, max_rotation))
			'-':
				turtle.rotate(-rand_range(min_rotation, max_rotation))
			'[':
				turtle.push()
				length *= length_factor
			']':
				turtle.pop()
				length /= length_factor


func _draw() -> void:
	for branch in branches:
		draw_line(branch.point1, branch.point2, colour, thickness)
