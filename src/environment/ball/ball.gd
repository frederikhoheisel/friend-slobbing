extends RigidBody3D


@onready var area_3d: Area3D = %Area3D


var source: int


func _ready() -> void:
	area_3d.body_entered.connect(on_ball_hit)
	#await get_tree().create_timer(5.0).timeout
	#self.queue_free()


func on_ball_hit(body: Node3D) -> void:
	if not self.is_multiplayer_authority():
		return
	
	if body.has_method('take_damage'):
		body.take_damage(1, source)
	
	self.queue_free()
