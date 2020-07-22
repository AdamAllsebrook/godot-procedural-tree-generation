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
# F: create branch and move forward
# [: push a new transformation onto the stack
# ]: pop a transformation from the stack 

const X := Vector3.RIGHT
const Y := Vector3.UP
const Z := Vector3.BACK

# must be an LSystem
export(Resource) var l_system

export(int) var start_length = 20
export(float) var length_factor = .9
export(float) var length_variance = .1
export(float, 0, 100) var start_thickness = 1
export(float) var thickness_factor = 1

export(float, 0, 360) var min_rotation = 15
export(float, 0, 360) var max_rotation = 35

export(Color) var colour = Color(1, 1, 1, 1)

export(int, 3, 20) var branch_num_sides = 5

# must be a LeafSettings
export(Resource) var leaf_settings

export(int) var random_seed = 0

export(bool) var gen setget do_gen

var branches: Array


func _ready() -> void:
	generate()


func generate() -> void:
	assert(l_system is LSystem, 'l_system must be a resource of type LSystem')
	assert(leaf_settings is LeafSettings, 'leaf settings must be a resource of type LeafSettings')
	seed(random_seed)
	
	var turtle: Turtle = Turtle.new()
	var sentence: String = l_system.generate()
	
	var length: float = start_length
	var thickness: float = start_thickness
	
	for character in sentence:
		match character:
			'F':
				turtle.create_branch(length, length_variance, thickness, colour)
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
	
	if has_node('GeneratedTreeMesh'):
		$GeneratedTreeMesh.free()
	
	var tree: Root = turtle.get_tree()
	var mesh: MeshInstance = tree.generate_mesh(branch_num_sides, start_thickness, colour, leaf_settings)
	mesh.set_name('GeneratedTreeMesh')
	add_child(mesh)
	

func do_gen(_b: bool) -> void:
	generate()
