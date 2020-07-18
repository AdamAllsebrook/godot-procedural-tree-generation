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

var branches := MeshAttributes.new()
var leaves := MeshAttributes.new()


func add_branch(attrs: MeshAttributes) -> void:
	branches.append_mesh_attributes(attrs)
	
func add_leaf(attrs: MeshAttributes) -> void:
	leaves.append_mesh_attributes(attrs)

func commit_mesh(colour: Color, leaf_texture: Texture) -> void:
	mesh = ArrayMesh.new()
	
	# add branch surface
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, branches.create_array())
	
	var mat = SpatialMaterial.new()
	mat.set_albedo(colour)
	mat.set_cull_mode(SpatialMaterial.CULL_DISABLED)

	set_surface_material(0, mat)

	# add leaf surface
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, leaves.create_array())
	mat = SpatialMaterial.new()
	mat.set_albedo(Color(0, 1, 0, 1))
	#mat.set_texture(0, leaf_texture)
	#mat.set_feature(0, true)
	mat.set_cull_mode(SpatialMaterial.CULL_DISABLED)

	set_surface_material(1, mat)
	
	#branches = null
	#leaves = null
