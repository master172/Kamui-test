extends Spatial

var mouse_mov
var mouse_mov_y
var sway_threshold = 5
var sway_lerp = 5

export var sway_left :Vector3
export var sway_right :Vector3
export var sway_up :Vector3
export var sway_down : Vector3
export var sway_normal :Vector3

func _ready():
	pass

func _input(event):
	if event is InputEventMouseMotion:
		mouse_mov = -event.relative.x
		mouse_mov_y = -event.relative.y
	

func _process(delta):
	if mouse_mov != null:
		if mouse_mov > sway_threshold:
			rotation = rotation.linear_interpolate(sway_left,sway_lerp * delta)
		elif mouse_mov < -sway_threshold:
			rotation = rotation.linear_interpolate(sway_right,sway_lerp * delta)
		else:
			rotation = rotation.linear_interpolate(sway_normal,sway_lerp * delta)
		if mouse_mov_y > sway_threshold:
			rotation = rotation.linear_interpolate(sway_up, sway_lerp * delta)
		elif mouse_mov < -sway_threshold:
			rotation = rotation.linear_interpolate(sway_down, sway_lerp * delta)
		else:
			rotation = rotation.linear_interpolate(sway_normal, sway_lerp * delta)