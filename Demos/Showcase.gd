extends Spatial


onready var camera_orbit: Spatial = $CameraOrbit
onready var current: int = 1


func _ready() -> void:
	if has_node('Trees/Tree' + str(current)):
		get_node('Trees/Tree' + str(current)).set_visible(true)


func _process(delta: float) -> void:
	camera_orbit.rotate_y(delta * PI / 2)


func on_timer_timeout() -> void:
	get_node('Trees/Tree' + str(current)).set_visible(false)
	current += 1
	if has_node('Trees/Tree' + str(current)):
		get_node('Trees/Tree' + str(current)).set_visible(true)
	else:
		current = 1
		get_node('Trees/Tree' + str(current)).set_visible(true)
