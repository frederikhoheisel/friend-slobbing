extends VehicleBody3D


@export var max_steer: float = 0.9
@export var engine_power: float = 300.0


var colliding: bool
var normal: Vector3


@onready var engine_sound: AudioStreamPlayer3D = %EngineSound
@onready var ground_raycast: RayCast3D = %GroundRaycast


func _physics_process(delta: float) -> void:
	self.steering = move_toward(self.steering, Input.get_axis("right", "left") * max_steer, delta * 10.0)
	self.engine_force = Input.get_axis("backward", "forward") * engine_power
	
	if ground_raycast.is_colliding():
		if !colliding:
			#self.position.y += 0.1
			self.engine_force = 0.0
		
		normal = ground_raycast.get_collision_normal()
		
		if normal.dot(self.global_basis.y) > 0.5:
			var xform: Transform3D = align_with_y(self.global_transform, normal)
			self.global_transform = self.global_transform.interpolate_with(xform, 0.2).orthonormalized()
	
	colliding = ground_raycast.is_colliding()
	
	_audio_effect(delta)


func _audio_effect(delta: float) -> void:
	var speed_factor: float = clamp(abs(self.linear_velocity.length()), 0.0, 1.0)
	var throttle_factor: float = clamp(abs(Input.get_axis("backward", "forward")), 0.0, 1.0)
	
	var target_volume: float = remap(speed_factor + (throttle_factor * 0.5), 0.0, 1.5, -15.0, -5.0)
	engine_sound.volume_db = lerp(engine_sound.volume_db, target_volume, delta * 5.0)
	
	var target_pitch: float = remap(speed_factor, 0.0, 1.0, 0.5, 3)
	if throttle_factor > 0.1: target_pitch += 0.2
	
	engine_sound.pitch_scale = lerp(engine_sound.pitch_scale, target_pitch, delta * 2.0)


func align_with_y(xform: Transform3D, new_y: Vector3) -> Transform3D:
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
