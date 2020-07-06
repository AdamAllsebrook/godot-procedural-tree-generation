extends Object
class_name Branch

var point1: Vector3
var point2: Vector3

func _init(p1: Vector3, p2: Vector3) -> void:
	point1 = p1
	point2 = p2

func create_mesh() -> ImmediateGeometry:
	var ig := ImmediateGeometry.new()
	
	ig.begin(Mesh.PRIMITIVE_LINE_STRIP)
	ig.add_vertex(point1)
	ig.add_vertex(point2)
	ig.end()
	
	return ig
