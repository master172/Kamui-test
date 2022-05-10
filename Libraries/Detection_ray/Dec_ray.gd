extends RayCast


func _ready():
	translation.x = PlayerPos.player_position.x
	translation.z = PlayerPos.player_position.z
	print(self.translation)
	PlayerPos.player_position.y = self.get_collision_point().y + 10.0
	print("tmep_position_set")
	PlayerPos.updated = true
	print("updated")
	print("PLayer_pose.pos"," ",PlayerPos.player_position)
	queue_free()


	

	
