extends Object
class_name Turtle2D

var stack := [TurtleTransform2D.new()]

func create_line(length: float) -> Branch2D:
	var transform: TurtleTransform2D = stack[-1]
	
	var point1 := get_current_point()
	transform.move_forward(-length)
	var point2 := get_current_point()
	
	return Branch2D.new(point1, point2)
	
func rotate(angle: float) -> void:
	var transform: TurtleTransform2D = stack[-1]
	transform.rotate(deg2rad(angle))
	
func push() -> void:
	stack.push_back(TurtleTransform2D.new())
	
func pop() -> void:
	stack.pop_back()
	
func get_current_point() -> Vector2:
	var rotation: float = 0
	var point := Vector2()
	
	for transform in stack:
		point += transform.position.rotated(rotation)
		rotation += transform.rotation
	
	return point
