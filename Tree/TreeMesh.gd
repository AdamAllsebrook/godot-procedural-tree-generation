tool
extends MeshInstance
class_name TreeMesh

var arr: Array
var num_indices: int = 0

var verts: PoolVector3Array
var uvs: PoolVector2Array
var normals: PoolVector3Array
var indices: PoolIntArray

func _init() -> void:
	arr = []
	arr.resize(Mesh.ARRAY_MAX)
	
	verts = PoolVector3Array()
	uvs = PoolVector2Array()
	normals = PoolVector3Array()
	indices = PoolIntArray()
	
func add_to_mesh(verts_: PoolVector3Array, uvs_: PoolVector2Array, 
		normals_: PoolVector3Array, indices_: PoolIntArray) -> void:
	
	verts.append_array(verts_)
	uvs.append_array(uvs_)
	normals.append_array(normals_)
	
	for i in (indices_.size()):
		indices_[i] = indices_[i] + num_indices
	num_indices += indices_.size()
	
	indices.append_array(indices_)

func commit_mesh(colour) -> void:
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_TEX_UV] = uvs
	arr[Mesh.ARRAY_NORMAL] = normals
	arr[Mesh.ARRAY_INDEX] = indices
	
	mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	
	var mat = SpatialMaterial.new()
	mat.set_albedo(colour)
	mat.set_cull_mode(SpatialMaterial.CULL_DISABLED)

	set_surface_material(0, mat)
