extends StaticBody3D


@export var health: int = 5


func take_damage(amount: int, source: int) -> void:
	health -= amount
	
	var player_to_notify: Player
	
	for current_player: Player in get_tree().get_nodes_in_group('Player'):
		if current_player.name == str(source):
			player_to_notify = current_player
			break
	
	if not player_to_notify:
		return
	
	player_to_notify.register_hit.rpc_id(source)
	
	if health <= 0:
		self.queue_free()
