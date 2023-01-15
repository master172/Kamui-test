extends RayCast


func _ready():
	translation.x = PlayerPos.player_position.x
	translation.z = PlayerPos.player_position.z
	PlayerPos.player_position.y = self.get_collision_point().y + 10.0
	PlayerPos.updated = true
	queue_free()


	

	
