extends RigidBody3D


@export var wheels: Array[Wheel]
@export var acceleration: float = 600.0
@export var max_speed: float = 20.0
@export var accel_curve: Curve
@export var tire_turn_speed: float = 2.0
@export var tire_max_turn_deg: float = 25.0

@export var skid_marks: Array[GPUParticles3D]


var motor_input: int = 0
var hand_break: bool = false
var is_slipping: bool = false


func _physics_process(delta: float) -> void:
	_basic_steering_rotation(delta)
	
	var grounded: bool = false
	var id: int = 0
	for wheel: Wheel in wheels:
		if wheel.is_colliding():
			grounded = true
		wheel.force_raycast_update()
		_do_single_suspension(wheel)
		_do_single_acceleration(wheel, delta)
		_do_single_traction(wheel, id)
		id += 1
	
	if grounded:
		self.center_of_mass = Vector3.ZERO
	else:
		self.center_of_mass = Vector3(turn_input * 0.2, - 0.5, 0.0)
	
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
func _basic_steering_rotation(delta: float) -> void:
	turn_input = Input.get_axis("right", "left") * tire_turn_speed
	
	if turn_input:
		%WheelFL.rotation.y = clampf(%WheelFL.rotation.y + turn_input * delta, 
			deg_to_rad(-tire_max_turn_deg), deg_to_rad(tire_max_turn_deg))
		%WheelFR.rotation.y = clampf(%WheelFR.rotation.y + turn_input * delta, 
			deg_to_rad(-tire_max_turn_deg), deg_to_rad(tire_max_turn_deg))
	else:
		%WheelFL.rotation.y = move_toward(%WheelFL.rotation.y, 0.0, tire_turn_speed * delta)
		%WheelFR.rotation.y = move_toward(%WheelFR.rotation.y, 0.0, tire_turn_speed * delta)


func _get_point_velocity(point: Vector3) -> Vector3:
	return self.linear_velocity + self.angular_velocity.cross(point - self.global_position)


func _do_single_traction(ray: Wheel, id: int) -> void:
	if not ray.is_colliding():
		return
	
	var steer_side_dir: Vector3 = ray.global_basis.x
	var tire_vel: Vector3 = _get_point_velocity(ray.wheel.global_position)
	var steering_x_vel: float = steer_side_dir.dot(tire_vel)
	
	var grip_factor: float = absf(steering_x_vel / tire_vel.length())
	var x_traction: float = ray.grip_curve.sample_baked(grip_factor)
	
	skid_marks[id].global_position = ray.get_collision_point() + Vector3.UP * 0.01
	skid_marks[id].look_at(skid_marks[id].global_position + self.global_basis.z)
	
	if not hand_break and grip_factor < 0.2:
		is_slipping = false
		skid_marks[id].emitting = false
	
	if hand_break:
		x_traction = 0.01
		if not skid_marks[id].emitting:
			skid_marks[id].restart()
	elif is_slipping:
		x_traction = 0.1
	
	var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
	var x_force: Vector3 = -steer_side_dir * steering_x_vel * x_traction * ((self.mass * gravity) / 4.0)
	
	var f_vel: float = -ray.global_basis.z.dot(tire_vel)
	var z_traction: float = 0.05
	var z_force: Vector3 = self.global_basis.z * f_vel * z_traction * ((self.mass * gravity) / 4.0)
	
	var force_pos: Vector3 = ray.wheel.global_position - self.global_position
	self.apply_force(x_force, force_pos)
	self.apply_force(z_force, force_pos)


func _do_single_acceleration(ray: Wheel, delta: float) -> void:
	var forward_dir: Vector3 = -ray.global_basis.z
	var vel: float = forward_dir.dot(self.linear_velocity)
	
	ray.wheel.rotate_x((-vel * delta) / ray.wheel_radius)
	
	if ray.is_colliding():
		var contact: Vector3 = ray.wheel.global_position
		var force_pos: Vector3 = contact - self.global_position
		
		if ray.is_motor and motor_input:
			var speed_ratio: float = vel / max_speed
			var ac: float = accel_curve.sample_baked(speed_ratio)
			var force_vector: Vector3 = forward_dir * acceleration * motor_input * ac
			self.apply_force(force_vector, force_pos)


func _do_single_suspension(ray: Wheel) -> void:
	if ray.is_colliding():
		ray.target_position.y = -(ray.rest_dist + ray.wheel_radius + ray.over_extend)
		var contact: Vector3 = ray.get_collision_point()
		var spring_up_dir: Vector3 = ray.global_transform.basis.y
		var spring_len: float = ray.global_position.distance_to(contact) - ray.wheel_radius
		var offset: float = ray.rest_dist - spring_len
		
		ray.get_child(0).position.y = -spring_len
		
		var spring_force: float = ray.spring_strength * offset
		
		var world_vel: Vector3 = _get_point_velocity(contact)
		var relative_vel: float = spring_up_dir.dot(world_vel)
		var spring_damp_force: float = ray.spring_damping * relative_vel
		
		var force_vector: Vector3 = (spring_force - spring_damp_force) * ray.get_collision_normal()
		
		print(force_vector)
		if force_vector.angle_to(Vector3.UP) < PI / 2.0:
			force_vector.y = 0.0
		
		contact = ray.wheel.global_position
		var force_pos: Vector3 = contact - self.global_position
		self.apply_force(force_vector, force_pos)
