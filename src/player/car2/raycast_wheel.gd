class_name Wheel
extends RayCast3D


@export_group("Wheel parameter")
@export var spring_strength: float = 5000.0
@export var spring_damping: float = 120.0
@export var rest_dist: float = 0.3
@export var over_extend: float = 0.0
@export var wheel_radius: float = 0.3
@export var z_traction: float = 0.05
@export var z_brake_traction: float = 0.25

@export_group("Motor")
@export var is_motor: bool = false
@export var is_steer: bool = false
@export var grip_curve: Curve

@export_group("Debug")
@export var debug: bool = false


var engine_force: float = 0.0
var grip_factor: float = 0.0
var is_braking: bool = false


@onready var wheel: MeshInstance3D = self.get_child(0)


func _ready() -> void:
	self.target_position.y = -(rest_dist + wheel_radius + over_extend)



func _apply_physics(car: RayCar, delta: float) -> void:
	self.force_raycast_update()
	self.target_position.y = -(rest_dist + wheel_radius + over_extend)
	
	# visuals
	var forward_dir: Vector3 = -global_basis.z
	var vel: float = forward_dir.dot(car.linear_velocity)
	wheel.rotate_x(-vel * delta / wheel_radius)
	
	if not self.is_colliding():
		return
	
	var contact: Vector3 = self.get_collision_point()
	var spring_length: float = maxf(0.0, self.global_position.distance_to(contact) - wheel_radius)
	var offset: float = rest_dist - spring_length
	
	
	wheel.position.y = move_toward(wheel.position.y, -spring_length, 5 * delta)
	contact = wheel.global_position
	var force_pos: Vector3 = contact - car.global_position
	
	
	var spring_force: float = spring_strength * offset
	var tire_vel: Vector3 = car._get_point_velocity(contact) ##TODO
	var spring_damp_force: float = spring_damping * self.global_basis.y.dot(tire_vel)
	
	var y_force: Vector3 = (spring_force - spring_damp_force) * self.get_collision_normal()
	
	# acceleration
	if is_motor and car.motor_input:
		var speed_ratio: float = vel / car.max_speed
		var ac: float = car.accel_curve.sample_baked(speed_ratio)
		var accel_force: Vector3 = -global_basis.z * car.acceleration * car.motor_input * ac
		car.apply_force(accel_force, force_pos)
	
	
	var steering_x_vel: float = self.global_basis.x.dot(tire_vel)
	
	grip_factor = absf(steering_x_vel / tire_vel.length())
	var x_traction: float = grip_curve.sample_baked(grip_factor)
	
	
	if not car.hand_break and grip_factor < 0.2:
		car.is_slipping = false
	if car.hand_break:
		x_traction = 0.01
	elif car.is_slipping:
		x_traction = 0.1
	
	var gravity: float = -car.get_gravity().y
	var x_force: Vector3 = -self.global_basis.x * steering_x_vel * x_traction * ((car.mass * gravity) / 4.0)
	
	
	var f_vel: float = forward_dir.dot(tire_vel)
	var z_friction: float = z_traction
	if is_braking:
		z_friction = z_brake_traction
	var z_force: Vector3 = self.global_basis.z * f_vel * z_friction * ((car.mass * gravity) / 4.0)
	
	car.apply_force(x_force, force_pos)
	car.apply_force(y_force, force_pos)
	car.apply_force(z_force, force_pos)
