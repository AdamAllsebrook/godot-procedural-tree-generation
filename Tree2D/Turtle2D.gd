class_name Turtle2D
extends Object


var transform_stack := [TurtleTransform2D.new()]


func create_line(length: float) -> Branch2D:
	var transform: TurtleTransform2D = transform_stack[-1]
	
	var point1 := get_current_point()
	transform.move_forward(-length)
	var point2 := get_current_point()
	
	return Branch2D.new(point1, point2)
	

func rotate(angle: float) -> void:
	var transform: TurtleTransform2D = transform_stack[-1]
	transform.rotate(deg2rad(angle))
	

func push() -> void:
	transform_stack.push_back(TurtleTransform2D.new())
	

func pop() -> void:
	transform_stack.pop_back()

	
# returns the point (0, 0) tranformed by each transformation from the stack
func get_current_point() -> Vector2:
	var rotation: float = 0
	var point := Vector2()
	
	for transform in transform_stack:
		point += transform.position.rotated(rotation)
		rotation += transform.rotation
	
	return point
