extends MeshInstance
class_name Branch

var point_a: Vector3
var point_b: Vector3
var rot_basis: Basis
var thickness: float
var colour: Color

func _init(a: Vector3, b: Vector3, rot: Basis, thick: float, col: Color) -> void:
	point_a = a
	point_b = b
	rot_basis = rot
	thickness = thick
	colour = col

func create_mesh() -> void:
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	
	var arr_attrs: Dictionary = create_prism(7, point_a, point_a.distance_to(point_b), thickness)
	
	arr[Mesh.ARRAY_VERTEX] = arr_attrs.verts
	arr[Mesh.ARRAY_TEX_UV] = arr_attrs.uvs
	arr[Mesh.ARRAY_NORMAL] = arr_attrs.normals
	arr[Mesh.ARRAY_INDEX] = arr_attrs.indices

	mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	
	var mat = SpatialMaterial.new()
	mat.set_albedo(colour)
	mat.set_cull_mode(SpatialMaterial.CULL_DISABLED)

	set_surface_material(0, mat)

func create_prism(num_sides: int, translation: Vector3, height: float, width: float) -> Dictionary:
	var verts := PoolVector3Array()
	var uvs := PoolVector2Array()
	var normals := PoolVector3Array()
	var indices := PoolIntArray()
	
	var centre := translation + rot_basis * Vector3(0, height / 2, 0)
	
	# create top and bottom faces
	var num_indices: int = 0
	for h in [0, height]:
		for i in (num_sides - 2):
			# create the vertices for the prism, not rotated or translated
			verts.append(get_prism_point(0.0, h, width))
			verts.append(get_prism_point(float(i+1) / num_sides, h, width))
			verts.append(get_prism_point(float(i+2) / num_sides, h, width))
			
			# calculate the normal for this triangle, including translation and rotation
			var normal: Vector3 = (centre - translation - rot_basis * Vector3(0, h, 0)).normalized()
			
			# create normals, uvs, indices
			for j in (3):
				normals.append(normal)
				uvs.append(Vector2())
				indices.append(num_indices + j)
			num_indices += 3
	
	# create sides
	for i in (num_sides):
		var theta: float = 2 * PI / num_sides
		# create the points for this face, not translated for rotated
		verts.append(get_prism_point(float(i) / num_sides, 0, width))
		verts.append(get_prism_point(float(i + 1) / num_sides, 0, width))
		verts.append(get_prism_point(float(i) / num_sides, height, width))
		
		verts.append(get_prism_point(float(i) / num_sides, height, width))
		verts.append(get_prism_point(float(i + 1) / num_sides, 0, width))
		verts.append(get_prism_point(float(i + 1) / num_sides, height, width))
		
		# calculate the normal for this face, including translation and rotation
		var normal := (centre - translation - rot_basis * Vector3(sin(theta * (i+.5)), height/2, cos(theta * (i+.5)))).normalized()
		
		# create normals, uvs, indices for this face
		for j in (6):
			normals.append(normal)
			uvs.append(Vector2())
			indices.append(num_indices + j)
		num_indices += 6
	
	# rotate and translate every point
	for i in (verts.size()):
		verts[i] = rot_basis * verts[i]
		verts[i] += translation
	
	return {
		verts = verts,
		uvs = uvs,
		normals = normals,
		indices = indices
	}
	
func get_prism_point(angle_percent: float, height: float, width: float) -> Vector3:
	return Vector3(sin(2 * PI * angle_percent) * width, height, cos(2 * PI * angle_percent) * width)
