extends Reference
class_name Branch

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

func add_to_mesh(mi: TreeMesh, bottom: Array, depth: int, leaf_settings: LeafSettings) -> void:
	var attrs: MeshAttributes = create_prism(bottom.size(), bottom, point_a, rot_basis, 
			point_a.distance_to(point_b), thickness)
	mi.add_branch(attrs)
#
	if depth >= leaf_settings.min_depth:
		var leaf_attrs: MeshAttributes = create_leaves_across_branch(point_a, rot_basis, 
				point_a.distance_to(point_b), thickness, leaf_settings)
		mi.add_leaf(leaf_attrs)
		#leaf_attrs = null

	if children.size() == 0:
		var leaf_attrs: MeshAttributes = create_leaf(point_b, rot_basis, leaf_settings)
		mi.add_leaf(leaf_attrs)
		#leaf_attrs = null
	
	for child in children:
		child.add_to_mesh(mi, attrs.data.top, depth + 1, leaf_settings)
		
	#attrs = null

static func create_prism(num_sides: int, bottom: Array, translation: Vector3, 
		rotation: Basis, height: float, width: float) -> MeshAttributes:
	
	var attrs := MeshAttributes.new()
	
	var centre_top := translation + rotation * Vector3(0, height, 0)
	var centre_bottom := translation
	
	var top := []
	
	# create points for top side
	for i in (num_sides):
		var v: Vector3 = get_prism_point(float(i) / num_sides, height, width)
		v = rotation * v
		v += translation
		top.append(v)
		
	# align bottom and top arrays
	# by rotating bottom array to the layout that has the least distance to the top array
	var distance_sums := []
	for i in (num_sides):
		var sum: float = 0
		for j in num_sides:
			sum += bottom[j].distance_to(top[j])
		distance_sums.append(sum)
		bottom.push_back(bottom.pop_front())
	for i in (distance_sums.find(distance_sums.min())):
		bottom.push_back(bottom.pop_front())
	
	# maybe create top/ bottom faces?
	
	# create top and bottom faces
#	var num_indices: int = 0
#	for h in [0, height]:
#		for i in (num_sides - 2):
#			# create the vertices for the prism, not rotated or translated
#			verts.append(get_prism_point(0.0, h, width))
#			verts.append(get_prism_point(float(i+1) / num_sides, h, width))
#			verts.append(get_prism_point(float(i+2) / num_sides, h, width))
#
#			# calculate the normal for this triangle, including translation and rotation
#			var normal: Vector3 = (centre - translation - rot_basis * Vector3(0, h, 0)).normalized()
#
#			# create normals, uvs, indices
#			for j in (3):
#				normals.append(normal)
#				uvs.append(Vector2())
#				indices.append(num_indices + j)
#			num_indices += 3

	# create sides
	for i in (num_sides):
#		#var theta: float = 2 * PI / num_sides
#
#		verts.append(bottom[i])
#		normals.append((centre_bottom - bottom[i]).normalized())
#		verts.append(bottom[(i+1) % num_sides])
#		normals.append((centre_bottom - bottom[(i+1) % num_sides]).normalized())
#		verts.append(top[i])
#		normals.append((centre_top - top[i]).normalized())
#
#		verts.append(top[i])
#		normals.append((centre_top - top[i]).normalized())
#		verts.append(bottom[(i+1) % num_sides])
#		normals.append((centre_bottom - bottom[(i+1) % num_sides]).normalized())
#		verts.append(top[(i+1) % num_sides])
#		normals.append((centre_top - top[(i+1) % num_sides]).normalized())
#
##		var centre_of_face: Vector3 = (bottom[i] + top[(i+1) % num_sides]) / 2
##		var normal: Vector3 = (centre - centre_of_face).normalized()
#
#		for j in (6):
#			#normals.append(normal)
#			uvs.append(Vector2())
#			indices.append(num_indices + j)
#		num_indices += 6
		
		for j in (6):
			attrs.append_uv(Vector2())
			attrs.append_index(j)
			
		attrs.append_verts(PoolVector3Array([
			bottom[i],
			bottom[(i+1) % num_sides],
			top[i],
			
			top[i],
			bottom[(i+1) % num_sides],
			top[(i+1) % num_sides],
		]))
		
		attrs.append_normals(PoolVector3Array([
			(centre_bottom - bottom[i]).normalized(),
			(centre_bottom - bottom[(i+1) % num_sides]).normalized(),
			(centre_top - top[i]).normalized(),
			
			(centre_top - top[i]).normalized(),
			(centre_bottom - bottom[(i+1) % num_sides]).normalized(),
			(centre_top - top[(i+1) % num_sides]).normalized(),
		]))

	attrs.data.top = top
	return attrs
	
static func get_prism_point(angle_percent: float, height: float, width: float) -> Vector3:
	return Vector3(sin(2 * PI * angle_percent) * width, height, cos(2 * PI * angle_percent) * width)

static func create_leaves_across_branch(translation: Vector3, rotation: Basis, 
		branch_height: float, branch_width: float, settings: LeafSettings) -> MeshAttributes:
	var attrs := MeshAttributes.new()
	
	for i in range(0, branch_height, 1 / settings.frequency):
		for j in [-1, 1]:
			var offset := Vector3((branch_width + settings.width / 2) * j, i, 0)
			var leaf_attrs: MeshAttributes = create_leaf(translation + rotation * offset, rotation, settings)
			attrs.append_mesh_attributes(leaf_attrs)
	
	return attrs

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
