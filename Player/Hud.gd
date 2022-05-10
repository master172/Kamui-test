extends Control

var using_kamui = false
export(bool) var can_use_kamui = true

onready var anim_player = $AnimatedSprite/AnimationPlayer
onready var kamui = $AnimatedSprite

func _use_kamui():
	if Input.is_action_just_pressed("kamui") and can_use_kamui == true:
		using_kamui = true
	else:
		using_kamui = false
	
	if using_kamui == true:
		anim_player.play("kamui_use")

		
func _physics_process(delta):
	
	_use_kamui()