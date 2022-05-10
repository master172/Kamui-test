extends Spatial

var grapple_point = Vector3()
var grappling = false
var gpoint_distance = 0

onready var grapplecast = get_parent().get_parent().get_child(1)
onready var player_hand = get_parent()
onready var player = get_parent().get_parent().get_parent().get_parent()
onready var grapple_timer = $Grapple_timer
onready var grapple = $Hook
onready var lookpoint = get_parent().get_child(1)
onready var Grapple_position = $Grapple_point
onready var Rope_position = $Hook/Rope_position
onready var gun = $Hook

const rope = preload("res://Libraries/Ropes/Grappling_rope.tscn")

var Rope

var rope_added = false
var rotated = false

func _ready() -> void:
	pass

#add time spent grappling to lerp, to counter for overchared negative gravity

func grapple(delta):
	if Input.is_action_just_pressed("ADS"):
		if grappling:
			grappling = false
	if Input.is_action_just_pressed("fire"):
		if grapplecast.is_colliding():
			
			var body = grapplecast.get_collider()
			if not body.is_in_group("player"):
				grapple_timer.start()
				find_point()
				if not grappling == true:
					grappling = true
	if grappling == true:
		rotated = false
		gun.scale.z = -0.1
		Grapple_position.global_transform.origin.x = grapple_point.x
		Grapple_position.global_transform.origin.y = grapple_point.y
		Grapple_position.global_transform.origin.z = grapple_point.z
		
		if rope_added == false: 
			Rope = rope.instance()
			Rope.global_transform.origin.x = Rope_position.global_transform.origin.x 
			Rope.global_transform.origin.y = Rope_position.global_transform.origin.y 
			Rope.global_transform.origin.z = Rope_position.global_transform.origin.z
			Rope.attach_end_to = Grapple_position.get_path()
			Rope.rope_width = 0.01
			self.add_child(Rope)
		
			rope_added = true
		Rope.global_transform.origin.x = Rope_position.global_transform.origin.x 
		Rope.global_transform.origin.y = Rope_position.global_transform.origin.y 
		Rope.global_transform.origin.z = Rope_position.global_transform.origin.z
		player.gravity = -20
		grapple.look_at(Grapple_position.global_transform.origin,Vector3(0,-1,0))
		grapple.rotate_object_local(Vector3(0,-1,0), 3.14)
		gpoint_distance = grapple_point.distance_to(player.transform.origin)
		if grapple_point.distance_to(player.transform.origin) > 1:
			player.transform.origin = lerp(player.transform.origin, grapple_point, 0.01)
			Rope.rope_length = 1.0
			
		if player.translation.y > grapple_point.y + 3:
			player.gravity = 20
			Rope.rope_length = 3.0
	else:
		gun.scale.x = -0.1
		Grapple_position.translation = Vector3(0,0,-100)
		if Rope != null:
			if is_instance_valid(Rope) and not rotated:
				Rope.queue_free()
			rope_added = false
		if grapple.rotation != Vector3(0,0,0):
			grapple.rotation = rotation.linear_interpolate(Vector3(0,0,0),0.1*delta)
			rotated = true
		if rotated == true:
			grapple.look_at(Vector3(lookpoint.global_transform.origin.x, lookpoint.global_transform.origin.y, lookpoint.global_transform.origin.z), Vector3(0,-1,0))
			grapple.rotate_object_local(Vector3(0,-1,0), 3.14)
		player.gravity = 20
	if Input.is_action_just_pressed("jump"):
		if grappling:
			player.gravity_vec = Vector3.UP * player.jump

func find_point():
	grapple_point = grapplecast.get_collision_point()
	Grapple_position.global_transform.origin.x = grapple_point.x
	Grapple_position.global_transform.origin.y = grapple_point.y
	Grapple_position.global_transform.origin.z = grapple_point.z


func _on_Grapple_timer_timeout() -> void:
	grappling = false
