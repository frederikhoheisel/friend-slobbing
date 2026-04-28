extends CanvasLayer


@export var car: RayCar


func _process(_delta: float) -> void:
	%FPS.text = str(Engine.get_frames_per_second())
	%SPEED.text = "speed: " + str(abs(car.global_basis.z.dot(car.linear_velocity)))
	%DebugLabel.text = str(car.turn_input)
