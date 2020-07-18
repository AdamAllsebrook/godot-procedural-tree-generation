tool
extends Spatial

# https://github.com/abiusx/L3D

# alphabet:
# +: turn right
# -: turn left
# &: pitch down
# ^: pitch up
# <: roll left /
# >: roll right \
# |: turn 180 degrees // not implemented
# F: create branch and move forward
# g: go forward // not implemented
# [: push a new transformation onto the stack
# ]: pop a transformation from the stack 

# must be an LSystem
export(Resource) var l_system

export(int) var start_length = 20
export(float) var length_factor = .9
export(float) var length_variance = .1
export(int, 1, 100) var start_thickness = 1
export(float) var thickness_factor = 1

export(float, 0, 360) var min_rotation = 15
export(float, 0, 360) var max_rotation = 35

export(Color) var colour = Color(1, 1, 1, 1)

export(int, 3, 20) var branch_num_sides = 5

# must be a LeafSettings
export(Resource) var leaf_settings

export(bool) var gen setget do_gen

var branches: Array

const X := Vector3.RIGHT
const Y := Vector3.UP
const Z := Vector3.BACK

func _ready() -> void:
	randomize()
	generate()

func generate() -> void:
	assert(l_system is LSystem, "l_system must be a resource of type LSystem")
	
	var turtle: Turtle = Turtle.new()
	var sentence: String = l_system.generate()
	
	var length: float = start_length
	var thickness: float = start_thickness
	
	for character in sentence:
		match character:
			'F':
				turtle.create_line(length, length_variance, thickness, colour)
			'+':
				turtle.rotate(X, rand_range(min_rotation, max_rotation))
			'-':
				turtle.rotate(X, -rand_range(min_rotation, max_rotation))
			'&':
				turtle.rotate(Z, rand_range(min_rotation, max_rotation))
			'^':
				turtle.rotate(Z, -rand_range(min_rotation, max_rotation))
			'<':
				turtle.rotate(Y, rand_range(min_rotation, max_rotation))
			'>':
				turtle.rotate(Y, -rand_range(min_rotation, max_rotation))
			'[':
				turtle.push()
				length *= length_factor
				thickness *= thickness_factor
			']':
				turtle.pop()
				length /= length_factor
				thickness /= thickness_factor
	
	for child in get_children():
		child.queue_free()
	
	var tree: Root = turtle.get_tree()
	var mesh: MeshInstance = tree.generate_mesh(branch_num_sides, start_thickness, colour, leaf_settings)
	add_child(mesh)
		
func do_gen(_b):
	generate()
