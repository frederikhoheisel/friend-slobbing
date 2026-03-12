extends VehicleBody3D


@export var max_steer: float = 0.9
@export var engine_power: float = 300.0


func _physics_process(delta: float) -> void:
	self.steering = move_toward(self.steering, Input.get_axis("right", "left") * max_steer, delta * 10.0)
	self.engine_force = Input.get_axis("backward", "forward") * engine_power
	
