extends Object
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

func add_to_mesh(mi: TreeMesh, bottom: Array) -> void:
	var attrs: Dictionary = create_prism(bottom.size(), bottom, point_a, point_a.distance_to(point_b), thickness)
	mi.add_to_mesh(attrs.verts, attrs.uvs, attrs.normals, attrs.indices)
	
	for child in children:
		child.add_to_mesh(mi, attrs.top)

func create_prism(num_sides: int, bottom: Array, translation: Vector3, height: float, width: float) -> Dictionary:
	var verts := PoolVector3Array()
	var uvs := PoolVector2Array()
	var normals := PoolVector3Array()
	var indices := PoolIntArray()
	
	var centre := translation + rot_basis * Vector3(0, height / 2, 0)
	
	var top := []
	
	# create points for top side
	for i in (num_sides):
		var v: Vector3 = get_prism_point(float(i) / num_sides, height, width)
		v = rot_basis * v
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
		
	var num_indices: int = 0
	
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
		#var theta: float = 2 * PI / num_sides
		
		verts.append(bottom[i])
		verts.append(bottom[(i+1) % num_sides])
		verts.append(top[i])
		
		verts.append(top[i])
		verts.append(bottom[(i+1) % num_sides])
		verts.append(top[(i+1) % num_sides])
		
		var centre_of_face: Vector3 = (bottom[i] + top[(i+1) % num_sides]) / 2
		var normal: Vector3 = (centre - centre_of_face).normalized()
		
		for j in (6):
			normals.append(normal)
			uvs.append(Vector2())
			indices.append(num_indices + j)
		num_indices += 6

	return {
		verts = verts,
		uvs = uvs,
		normals = normals,
		indices = indices,
		top = top
	}
	
func get_prism_point(angle_percent: float, height: float, width: float) -> Vector3:
	return Vector3(sin(2 * PI * angle_percent) * width, height, cos(2 * PI * angle_percent) * width)
