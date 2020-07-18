tool
extends Branch
class_name Root

func _init().(Vector3(), Vector3(), Basis(), 0, Color()) -> void:
	pass

func generate_mesh(num_sides: int, thick: float, colour: Color, leaf_settings: LeafSettings) -> TreeMesh:
	var mi: TreeMesh = TreeMesh.new()
	
	var base_points := []
	for i in (num_sides):
		base_points.append(.get_prism_point(float(i) / num_sides, 0.0, thick))
		
	for child in children:
		child.add_to_mesh(mi, base_points, 1, leaf_settings)
		
	mi.commit_mesh(colour, leaf_settings.texture)
	
	return mi
