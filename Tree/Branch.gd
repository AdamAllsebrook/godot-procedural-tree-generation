class_name Branch
extends Reference


var point_a: Vector3
var point_b: Vector3
var rot_basis: Basis
var thickness: float
var colour: Color

var children: Array = []
var parent: Branch


func _init(a: Vector3, b: Vector3, rot: Basis, thick: float, col: Color) -> void:
	point_a = a
	point_b = b
	rot_basis = rot
	thickness = thick
	colour = col
	
	
func add_child_branch(child: Branch) -> void:
	children.append(child)
	
	
func set_parent_branch(p: Branch) -> void:
	parent = p
	
	
func get_parent_branch() -> Branch:
	return parent
	
	
# bottom: an array of vertices for the bottom side of the branch
# depth: the number of branches away from the root this branch is
func add_to_tree_mesh(tree_mesh: TreeMesh, bottom: Array, depth: int, leaf_settings: LeafSettings) -> void:
	# create points for the top of the branch
	var top: Array = create_top_points(bottom.size(), point_a, rot_basis, 
			thickness, point_a.distance_to(point_b))
	
	# create branch
	var attrs: MeshAttributes = create_mesh(bottom.size(), bottom, top, point_a, 
			rot_basis, point_a.distance_to(point_b))
	tree_mesh.add_branch(attrs)

	# create leaves along branch
	if depth >= leaf_settings.min_depth:
		var leaf_attrs: MeshAttributes = create_leaves_across_branch(point_a, rot_basis, 
				thickness, point_a.distance_to(point_b), leaf_settings)
		tree_mesh.add_leaf(leaf_attrs)

	# add leaf to end
	if children.size() == 0:
		var leaf_attrs: MeshAttributes = create_leaf(point_b, rot_basis, leaf_settings)
		tree_mesh.add_leaf(leaf_attrs)
	
	# repeat for children
	for child in children:
		child.add_to_tree_mesh(tree_mesh, top, depth + 1, leaf_settings)
	
	
# create points for the top side of the branch
func create_top_points(num_points: int, translation: Vector3, rotation: Basis,
		width: float, height: float) -> Array:
	
	var top := []
	for i in (num_points):
		var v: Vector3 = get_prism_point(float(i) / num_points, width, height)
		v = rotation * v
		v += translation
		top.append(v)
	
	return top
	
	
static func create_mesh(num_sides: int, bottom: Array, top: Array, translation: Vector3, 
		rotation: Basis, height: float) -> MeshAttributes:
	
	var attrs := MeshAttributes.new()
	
	var centre_top := translation + rotation * Vector3(0, height, 0)
	var centre_bottom := translation
	
	# align bottom and top arrays
	# by rotating bottom array to the layout that has the least distance to the top array
	var distance_sums := []
	# get the distance for each layout
	for i in (num_sides):
		var sum: float = 0
		for j in num_sides:
			sum += bottom[j].distance_to(top[j])
		distance_sums.append(sum)
		bottom.push_back(bottom.pop_front())
	# rotate to the closest layout
	for i in (distance_sums.find(distance_sums.min())):
		bottom.push_back(bottom.pop_front())
	
	# create sides
	for i in (num_sides):
		attrs.append_indices(PoolIntArray([
			i,
			i + num_sides,
			(i + 1) % num_sides,
			
			(i + 1) % num_sides,
			i + num_sides,
			(i + 1) % num_sides + num_sides,
		]))
	
	for i in (num_sides * 2):
		attrs.append_uv(Vector2())
	
	attrs.append_verts(PoolVector3Array(top))
	attrs.append_verts(PoolVector3Array(bottom))
	
	for vertex in top:
		attrs.append_normal((centre_top - vertex).normalized())
	for vertex in bottom:
		attrs.append_normal((centre_bottom - vertex).normalized())
	
	return attrs
	
	
# returns the point on the branch prism, given how far around the prism the point is,
# the width of the prism,
# how high up the prism the point is 
static func get_prism_point(angle_percent: float, width: float, height: float) -> Vector3:
	return Vector3(sin(2 * PI * angle_percent) * width, height, cos(2 * PI * angle_percent) * width)
	
	
# create leaves parallel to and on either side of the branch at a regular frequency
static func create_leaves_across_branch(translation: Vector3, rotation: Basis, 
		branch_width: float, branch_height: float, settings: LeafSettings) -> MeshAttributes:
	var attrs := MeshAttributes.new()
	
	for i in range(0, branch_height, 1 / settings.frequency):
		for j in [-1, 1]:
			var offset := Vector3((branch_width + settings.width / 2) * j, i, 0)
			var leaf_attrs: MeshAttributes = create_leaf(translation + rotation * offset, rotation, settings)
			attrs.append_mesh_attributes(leaf_attrs)
	
	return attrs
	
	
# create a single leaf given the point where it attaches to the branch, 
# the rotation and the leaf settings for this tree.
# the leaf is a flat rectangle
static func create_leaf(translation: Vector3, rotation: Basis, settings: LeafSettings) -> MeshAttributes:
	var attrs := MeshAttributes.new()
	
	attrs.append_verts(PoolVector3Array([
		translation + rotation * Vector3(-settings.width / 2, 0, 0),
		translation + rotation * Vector3(settings.width / 2, 0, 0),
		translation + rotation * Vector3(-settings.width / 2, settings.height, 0),
		translation + rotation * Vector3(settings.width / 2, settings.height, 0),
	]))
	
	attrs.append_uvs(PoolVector2Array([
		Vector2(0, 0),
		Vector2(1, 0),
		Vector2(0, 1),
		Vector2(1, 1),
	]))
	
	var v1: Vector3 = attrs.verts[0] - attrs.verts[1]
	var v2: Vector3 = attrs.verts[0] - attrs.verts[2]
	var normal: Vector3 = (v2.cross(v1)).normalized()
	
	for i in (4):
		attrs.append_normal(normal)
	attrs.append_indices(PoolIntArray([0, 1, 2, 2, 1, 3]), false)
	
	return attrs
