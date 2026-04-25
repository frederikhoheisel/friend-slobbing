class_name RayCar
extends RigidBody3D


@export var wheels: Array[Wheel]
@export var acceleration: float = 600.0
@export var max_speed: float = 20.0
@export var accel_curve: Curve
@export var tire_turn_speed: float = 2.0
@export var tire_max_turn_deg: float = 25.0

@export var skid_marks: Array[GPUParticles3D]

@export var debug_visuals: bool = false

var motor_input: int = 0
var hand_break: bool = false
var is_slipping: bool = false


func _physics_process(delta: float) -> void:
	var grounded: bool = false
	var id: int = 0
	
	for wheel: Wheel in wheels:
		wheel._apply_physics(self, delta)
		_basic_steering_rotation(wheel, delta)
		
		if Input.is_action_pressed("brake"):
			wheel.is_braking = true
		else:
			wheel.is_braking = false
		
		skid_marks[id].global_position = wheel.get_collision_point() + Vector3.UP * 0.01
		skid_marks[id].look_at(skid_marks[id].global_position + self.global_basis.z)
		
		if not hand_break and wheel.grip_factor < 0.2:
			is_slipping = false
			skid_marks[id].emitting = false
	
		if hand_break and not skid_marks[id].emitting:
				skid_marks[id].emitting = true
		
		if wheel.is_colliding():
			grounded = true
		
		id += 1
	
	if grounded:
		self.center_of_mass = Vector3(0.0, -0.1, 0.0)
	else:
		self.center_of_mass = Vector3(turn_input * 0.2, - 0.5, 0.0)
	
	if debug_visuals:
		%CoM.position = self.center_of_mass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("handbreak"):
		hand_break = true
		is_slipping = true
	elif event.is_action_released("handbreak"):
		hand_break = false
	
	if event.is_action_pressed("forward"):
		motor_input = 1
	elif  event.is_action_released("forward"):
		motor_input = 0
	
	if event.is_action_pressed("backward"):
		motor_input = -1
	elif  event.is_action_released("backward"):
		motor_input = 0


var turn_input: float
func _basic_steering_rotation(wheel: Wheel, delta: float) -> void:
	if not wheel.is_steer: return
	
	turn_input = Input.get_axis("right", "left") * (clampf(tire_turn_speed - pow(self.linear_velocity.length() * 0.05, 2.0), 0.0, 1.0))
	
	if turn_input:
		wheel.rotation.y = clampf(wheel.rotation.y + turn_input * delta, 
			deg_to_rad(-tire_max_turn_deg), deg_to_rad(tire_max_turn_deg))
	else:
		wheel.rotation.y = move_toward(wheel.rotation.y, 0.0, tire_turn_speed * delta)


func _get_point_velocity(point: Vector3) -> Vector3:
	return self.linear_velocity + self.angular_velocity.cross(point - self.global_position)
