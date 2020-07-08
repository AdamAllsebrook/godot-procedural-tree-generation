extends MeshInstance
class_name Branch

var point_a: Vector3
var point_b: Vector3

func _init(a: Vector3, b: Vector3) -> void:
	point_a = a
	point_b = b

func create_mesh() -> void:
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	
	var a_to_b: Vector3 = point_b - point_a
	#var height = a_to_b.length()
	
	var arr_attrs: Dictionary = create_prism(7, point_a, a_to_b, 2)
	
	arr[Mesh.ARRAY_VERTEX] = arr_attrs.verts
	arr[Mesh.ARRAY_TEX_UV] = arr_attrs.uvs
	arr[Mesh.ARRAY_NORMAL] = arr_attrs.normals
	arr[Mesh.ARRAY_INDEX] = arr_attrs.indices

	mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	
	var mat = SpatialMaterial.new()
	mat.set_albedo(Color(1, 0, 0, 1))
	mat.set_cull_mode(SpatialMaterial.CULL_DISABLED)

	set_surface_material(0, mat)

func create_prism(num_sides: int, start: Vector3, end: Vector3, width: float) -> Dictionary:
	var verts := PoolVector3Array()
	var uvs := PoolVector2Array()
	var normals := PoolVector3Array()
	var indices := PoolIntArray()
	
	var centre := start + end / 2
	
	var height := 1
	# create top and bottom faces
	var n: int = 0
	for h in [0, height]:
		for i in (num_sides - 2):
			var theta: float = 2 * PI / num_sides
			verts.append(Vector3(0, h, 1))
			verts.append(get_prism_point(float(i+1) / num_sides, h))
			verts.append(get_prism_point(float(i+2) / num_sides, h))
			for j in (3):
				normals.append((Vector3(0, h, 0) - centre).normalized())
				uvs.append(Vector2())
				indices.append(n + j)
			n += 3
	
	# create sides
	for i in (num_sides):
		var theta: float = 2 * PI / num_sides
		verts.append(get_prism_point(float(i) / num_sides, 0))
		verts.append(get_prism_point(float(i + 1) / num_sides, 0))
		verts.append(get_prism_point(float(i) / num_sides, height))
		
		verts.append(get_prism_point(float(i) / num_sides, height))
		verts.append(get_prism_point(float(i + 1) / num_sides, 0))
		verts.append(get_prism_point(float(i + 1) / num_sides, height))
		
		
		for j in (6):
			uvs.append(Vector2())
			normals.append((Vector3(sin(theta * (i+.5)), height/2, cos(theta * (i+.5))) - centre).normalized())
			indices.append(n + j)
		n += 6
		
	for i in (verts.size()):
#		verts[i].x *= scale.x
#		verts[i].y *= scale.y
#		verts[i].z *= scale.z

		verts[i] += start
	
	return {
		verts = verts,
		uvs = uvs,
		normals = normals,
		indices = indices
	}
	
func get_prism_point(angle_percent: float, height: float) -> Vector3:
	return Vector3(sin(2 * PI * angle_percent), height, cos(2 * PI * angle_percent))
