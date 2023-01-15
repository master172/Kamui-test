extends KinematicBody

var speed = 20
var def_speed = 20
var def_jump = 10
var max_jump = 20
var h_acceleration = 20
var air_acceleration = 60
var normal_acceleration = 20
var gravity = 20
var jump = 10
var jump_nun = 0
var mouse_sensitivity = 0.05
var wall_run_delay = 0.2
var wall_run_angle = 25
var wall_run_current_rotation = 0
var side = ""
var wall_jump_horizontal_power = 2
var wall_jump_vertical_power = 1.75
var wall_jump_factor = 0.7
var max_exaustion = 0
var max_stamina = 3000
var stamina = 3000
var sprint_speed = 40

var full_contact = false
var crosshair_played = false
var can_wall_run = false
var is_wall_running :bool = false
var is_wallrun_jumping :bool = false
var is_sprinting : bool = false


var direction = Vector3()
var h_velocity = Vector3()
var movement = Vector3()
var gravity_vec = Vector3()
var wall_jump_dir = Vector3()



onready var head = $Head
onready var ground_check = $GroundCheck
onready var aim = $Head/Camera/RayCast
onready var crosshair = $Head/Camera/Control/TextureRect/AnimatedSprite
onready var Grappling_gun = $Head/Camera/Hand/Grappling_gun
onready var Head_bonker = $Head_bonker
onready var wall_run_delay_default = wall_run_delay
onready var sprint_progress = $Head/Camera/Control/ProgressBar


onready var Main_cam = $Head/Camera
onready var Gun_cam = $Head/Camera/ViewportContainer/Viewport/Gun_cam

func _process(_delta):
	Gun_cam.global_transform = Main_cam.global_transform

func _wall_run_rotation(delta):
	if is_wall_running:

		if side == "RIGHT":
			wall_run_current_rotation += delta * 240
			wall_run_current_rotation = clamp(wall_run_current_rotation, -wall_run_angle, wall_run_angle)
		elif side == "LEFT":
			wall_run_current_rotation -= delta * 240
			wall_run_current_rotation = clamp(wall_run_current_rotation, -wall_run_angle, wall_run_angle)
	
	else:
		if wall_run_current_rotation > 0:
			wall_run_current_rotation -= delta * 120
			wall_run_current_rotation = max(0,wall_run_current_rotation)
		elif wall_run_current_rotation < 0:
			wall_run_current_rotation += delta * 120
			wall_run_current_rotation = min(wall_run_current_rotation,0)
		
	self.rotation_degrees.z = 1 * wall_run_current_rotation

func _get_side(point):
	point = to_local(point)

	if point.x > 0:
		return "RIGHT"
	elif point.x < 0:
		return "LEFT"
	else:
		return "CENTER" 


func _process_wall_run():
	if can_wall_run:
		if is_on_wall() and  Input.is_action_pressed("move_forward") and Input.is_action_pressed("sprint"):
			var collision = get_slide_collision(0)
			var normal = collision.normal

			var wall_run_dir = Vector3.UP.cross(normal)

			var player_view_dir = -Main_cam.global_transform.basis.z
			var dot = wall_run_dir.dot(player_view_dir)

			if dot < 0:
				wall_run_dir = - wall_run_dir

			var wall_run_axis_2d = Vector2(wall_run_dir.x, wall_run_dir.z)
			var view_ais_2d = Vector2(player_view_dir.x, player_view_dir.z)
			var angle = wall_run_axis_2d.angle_to(view_ais_2d)

			angle = rad2deg(angle)

			if angle > 85:
				is_wall_running = false
				return


			wall_run_dir += -normal * 0.01

			is_wall_running = true

			side = _get_side(collision.position)

			gravity = 0
			gravity_vec = Vector3(0,0,0)
			direction = wall_run_dir
		else:
			is_wall_running = false


func _head_bonk():
	if Head_bonker.is_colliding():
		var body = Head_bonker.get_collider()
		if !body.is_in_group("Player"):
			
			
			Grappling_gun.grappling = false
			Grappling_gun.grapple_point = null
			
		
			
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
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(83))
	
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

	sprint_progress.value = stamina

	if Input.is_action_pressed("sprint") and stamina > max_exaustion and direction != Vector3.ZERO:
		stamina -= 100 * delta
		speed = sprint_speed
		jump = max_jump
		is_sprinting = true
	else:
		speed = def_speed
		jump = def_jump
		is_sprinting = false
	if stamina < max_stamina and not is_sprinting:
		stamina += 100 * delta
	if stamina > max_stamina:
		stamina = max_stamina

	if stamina <= max_exaustion:
		speed = def_speed
		jump = def_jump

	_process_wall_run()
	_wall_run_rotation(delta)


	_head_bonk()

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
		can_wall_run = false
		wall_run_delay = wall_run_delay_default
		is_wall_running = false
		is_wallrun_jumping = false
	else:
		wall_run_delay = clamp(wall_run_delay - delta , 0, wall_run_delay_default)

		if wall_run_delay == 0:
			can_wall_run = true
	if Input.is_action_just_pressed("jump") and (is_on_floor() or ground_check.is_colliding()) and jump_nun == 0:
		gravity_vec = Vector3.UP * jump
		jump_nun = 1

	elif Input.is_action_just_pressed("jump") and jump_nun == 1:
		gravity_vec = Vector3.UP * jump
		jump_nun = 2
	
	if Input.is_action_just_pressed("jump") and is_wall_running:
		can_wall_run = false
		is_wall_running = false


		movement.y = jump * wall_jump_vertical_power
		is_wallrun_jumping = true

		if side == "LEFT":
			wall_jump_dir = global_transform.basis.x * wall_jump_horizontal_power
		elif side == "RIGHT":
			wall_jump_dir = -global_transform.basis.x * wall_jump_horizontal_power

		wall_jump_dir *= wall_jump_factor
	
	if is_wallrun_jumping:
		direction = (direction * (1 -wall_jump_factor)) + wall_jump_dir
	
	
	
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


