tool
class_name TurtleTransform
extends Reference


var position := Vector3()
var rotation := Basis()


func rotate(axis: Vector3, angle: float) -> void:
	rotation = rotation.rotated(axis, angle)

	
func move_forward(distance: float) -> void:
	position += rotation * Vector3(0, distance, 0)
