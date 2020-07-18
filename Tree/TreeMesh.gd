tool
extends MeshInstance
class_name TreeMesh

var branch_arr := []
var branch_num_verts: int = 0
var branch_verts := PoolVector3Array()
var branch_uvs := PoolVector2Array()
var branch_normals := PoolVector3Array()
var branch_indices := PoolIntArray()

var leaf_arr := []
var leaf_num_verts: int = 0
var leaf_verts := PoolVector3Array()
var leaf_uvs := PoolVector2Array()
var leaf_normals := PoolVector3Array()
var leaf_indices := PoolIntArray()

func _init() -> void:
	branch_arr.resize(Mesh.ARRAY_MAX)
	leaf_arr.resize(Mesh.ARRAY_MAX)
	
func add_branch(verts_: PoolVector3Array, uvs_: PoolVector2Array, 
		normals_: PoolVector3Array, indices_: PoolIntArray) -> void:
	
	branch_verts.append_array(verts_)
	branch_uvs.append_array(uvs_)
	branch_normals.append_array(normals_)
	
	for i in (indices_.size()):
		indices_[i] = indices_[i] + branch_num_verts
	branch_num_verts += verts_.size()
	
	branch_indices.append_array(indices_)
	
func add_leaf(verts_: PoolVector3Array, uvs_: PoolVector2Array, 
		normals_: PoolVector3Array, indices_: PoolIntArray) -> void:
	
	leaf_verts.append_array(verts_)
	leaf_uvs.append_array(uvs_)
	leaf_normals.append_array(normals_)
	
	for i in (indices_.size()):
		indices_[i] = indices_[i] + leaf_num_verts
	leaf_num_verts += verts_.size()
	
	leaf_indices.append_array(indices_)

func commit_mesh(colour: Color, leaf_texture: Texture) -> void:
	print('polygon count: ', branch_indices.size() / 6)
	
	branch_arr[Mesh.ARRAY_VERTEX] = branch_verts
	branch_arr[Mesh.ARRAY_TEX_UV] = branch_uvs
	branch_arr[Mesh.ARRAY_NORMAL] = branch_normals
	branch_arr[Mesh.ARRAY_INDEX] = branch_indices
	
	leaf_arr[Mesh.ARRAY_VERTEX] = leaf_verts
	leaf_arr[Mesh.ARRAY_TEX_UV] = leaf_uvs
	leaf_arr[Mesh.ARRAY_NORMAL] = leaf_normals
	leaf_arr[Mesh.ARRAY_INDEX] = leaf_indices
	
	mesh = ArrayMesh.new()
	
	# add branch surface
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, branch_arr)
	
	var mat = SpatialMaterial.new()
	mat.set_albedo(colour)
	mat.set_cull_mode(SpatialMaterial.CULL_DISABLED)

	set_surface_material(0, mat)
	
	# add leaf surface
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, leaf_arr)
	mat = SpatialMaterial.new()
	mat.set_albedo(Color(0, 1, 0, 1))
	#mat.set_texture(0, leaf_texture)
	mat.set_feature(0, true)
	mat.set_cull_mode(SpatialMaterial.CULL_DISABLED)

	set_surface_material(1, mat)
