extends Spatial

onready var Dec_ray = preload("res://Libraries/Detection_ray/Dec_ray.tscn")


onready var kamui_environment = preload("res://World/Kamui_world.tres")
onready var main_environment = preload("res://World/World_1.tres")

onready var kamui_scene= preload("res://World/Kamui_world.tscn")
onready var Main_scene = preload("res://World/World_1.tscn")

onready var world_environment = $WorldEnvironment
onready var kamui_timer = $kamui_timer

onready var current_scene = $current_scene

var kamui_world = false

const player = preload("res://Player/Player_1.tscn")

func _physics_process(_delta):
	if Input.is_action_just_pressed("kamui") and kamui_world == false:
		kamui_timer.start()
		
	elif Input.is_action_just_pressed("kamui") and kamui_world == true:
		kamui_timer.start()
	


func _on_kamui_timer_timeout():
	if kamui_world == false:
		world_environment.environment = kamui_environment
		current_scene.get_children().back().find_node("Player_1")._update_pos()
		current_scene.get_child(0).queue_free()
		current_scene.add_child(kamui_scene.instance())		
		if PlayerPos.updated == true:
			current_scene.get_children().back().find_node("Player_1")._update_self_pos()
		kamui_world = true	
	elif kamui_world == true:
		world_environment.environment = main_environment
		current_scene.get_children().back().find_node("Player_1")._update_pos()
		current_scene.get_child(0).queue_free()
		current_scene.add_child(Main_scene.instance())
		var dec_ray = Dec_ray.instance()
		current_scene.get_child(1).add_child(dec_ray)	
		if PlayerPos.updated == true:
			current_scene.get_children().back().find_node("Player_1")._update_self_pos()				
		kamui_world = false	
