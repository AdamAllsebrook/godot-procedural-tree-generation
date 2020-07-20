tool
class_name Root
extends Branch


# initialise as a branch with all attributes set to 0
func _init().(Vector3(), Vector3(), Basis(), 0, Color()) -> void:
	pass


# generate the tree mesh
func generate_mesh(num_sides: int, thick: float, colour: Color, leaf_settings: LeafSettings) -> TreeMesh:
	var tree_mesh: TreeMesh = TreeMesh.new()
	
	# create the points that the first branches will use as the bottom side
	var base_points := []
	for i in (num_sides):
		base_points.append(.get_prism_point(float(i) / num_sides, thick, 0.0))
	
	# add child branches to the tree
	for child in children:
		child.add_to_tree_mesh(tree_mesh, base_points, 1, leaf_settings)
		
	tree_mesh.commit_mesh(colour, leaf_settings.colour)
	
	return tree_mesh
