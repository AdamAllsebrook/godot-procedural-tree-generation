extends Object
class_name TurtleTransform2D

var rotation = 0
var position = Vector2()

func rotate(angle: float) -> void:
	rotation += angle
	
func move_forward(distance: float) -> void:
	var direction := Vector2(0, distance).rotated(rotation)
	position += direction
