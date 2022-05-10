extends KinematicBody

var speed = 20
var h_acceleration = 20
var air_acceleration = 6
var normal_acceleration = 20
var gravity = 20
var jump = 10
var jump_nun = 0
var mouse_sensitivity = 0.05

var full_contact = false
var crosshair_played = false


var direction = Vector3()
var h_velocity = Vector3()
var movement = Vector3()
var gravity_vec = Vector3()



onready var head = $Head
onready var ground_check = $GroundCheck
onready var aim = $Head/Camera/RayCast
onready var crosshair = $Head/Camera/Control/TextureRect/AnimatedSprite
onready var Grappling_gun = $Head/Camera/Hand/Grappling_gun

onready var Main_cam = $Head/Camera
onready var Gun_cam = $Head/Camera/ViewportContainer/Viewport/Gun_cam

func _process(delta):
	Gun_cam.global_transform = Main_cam.global_transform

func _update_crosshair():
	if aim.is_colliding() and crosshair_played == false:
		crosshair.play("Cross_hair_aim")
		crosshair_played = true
	elif aim.is_colliding() and crosshair_played == true:
		crosshair.play("Cross_hair_aimed")
		crosshair_played = true
	if !aim.is_colliding() and crosshair_played == true:
		crosshair.play("Cross_hair_merge")
		crosshair_played = false
	elif !aim.is_colliding() and crosshair_played == false:
		crosshair.play("Cross_hair_regular")
		crosshair_played = false


func _grapple_fire(delta):
	Grappling_gun.grapple(delta)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-85), deg2rad(85))
	
	if event.is_action_pressed("ui_cancel") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif  event.is_action_pressed("ui_cancel") and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _update_pos():
	PlayerPos.player_position = self.translation
	PlayerPos.player_rotation = self.rotation
	PlayerPos.player_camera_rotation = self.head.rotation

func _update_self_pos():
	self.translation = PlayerPos.player_position
	self.rotation = PlayerPos.player_rotation
	self.head.rotation = PlayerPos.player_camera_rotation

func _physics_process(delta):

	_grapple_fire(delta)

	_update_crosshair()
	
	
	direction = Vector3()
	
	full_contact = ground_check.is_colliding()
	
	if not is_on_floor():
		gravity_vec += Vector3.DOWN * gravity * delta
		h_acceleration = air_acceleration
	elif is_on_floor() and full_contact:
		gravity_vec = -get_floor_normal() * gravity
		h_acceleration = normal_acceleration
	else:
		gravity_vec = -get_floor_normal()
		h_acceleration = normal_acceleration
	
	if is_on_floor():
		jump_nun = 0
	if Input.is_action_just_pressed("jump") and (is_on_floor() or ground_check.is_colliding()) and jump_nun == 0:
		gravity_vec = Vector3.UP * jump
		jump_nun = 1
	elif Input.is_action_just_pressed("jump") and jump_nun == 1:
		gravity_vec = Vector3.UP * jump
		jump_nun = 2
		
	
	
	
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	elif Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	elif Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	
	direction = direction.normalized()
	h_velocity = h_velocity.linear_interpolate(direction * speed, h_acceleration * delta)
	movement.z = h_velocity.z + gravity_vec.z
	movement.x = h_velocity.x + gravity_vec.x
	movement.y = gravity_vec.y
	

	
	move_and_slide(movement, Vector3.UP)
