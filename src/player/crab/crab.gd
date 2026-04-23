class_name Player
extends CharacterBody3D


const SPEED: float = 2.0
const JUMP_VELOCITY: float = 2.5


var immobile: bool = false
var jumping: bool = false


@onready var ik_target_fl: IKTarget = %IKTargetFL
@onready var ik_target_bl: IKTarget = %IKTargetBL
@onready var ik_target_fr: IKTarget = %IKTargetFR
@onready var ik_target_br: IKTarget = %IKTargetBR

@onready var hud: CanvasLayer = %HUD
@onready var nameplate: Label3D = %Nameplate
@onready var camera_3d: Camera3D = %Camera3D


func _enter_tree() -> void:
	self.set_multiplayer_authority(int(name), true)


func _ready() -> void:
	self.add_to_group('Player')
	nameplate.text = self.name
	
	if not self.is_multiplayer_authority():
		self.set_process(false)
		self.set_physics_process(false)
		return
	
	if Global.username:
		nameplate.text = Global.username


func _process(delta: float) -> void:
	if Input.is_action_just_pressed('menu'):
		hud.open_menu()
		immobile = not immobile
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("shoot") and not immobile:
		shoot()
	#var plane1: Plane = Plane(ik_target_bl.global_position, ik_target_fl.global_position, ik_target_fr.global_position)
	#var plane2: Plane = Plane(ik_target_fr.global_position, ik_target_br.global_position, ik_target_bl.global_position)
	#var avg_normal: Vector3 = (plane1.normal + plane2.normal).normalized()
	
	#var target_basis: Basis = _basis_from_normal(avg_normal)
	#self.transform.basis = lerp(self.transform.basis, target_basis, SPEED * delta).orthonormalized()
	
	#var avg_pos: Vector3 = (ik_target_fl.global_position + ik_target_bl.global_position + ik_target_fr.global_position + ik_target_br.global_position) / 4.0
	#var target_pos: Vector3 = avg_pos + self.transform.basis.y * 0.5
	#var ground_distance: float = self.transform.basis.y.dot(target_pos)
	
	#self.global_position = lerp(self.global_position, self.global_position * self.transform.basis.y * ground_distance, SPEED * delta)
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	
	if immobile:
		direction = Vector3.ZERO
	
	if direction:
		self.velocity.x = direction.x * SPEED
		self.velocity.z = direction.z * SPEED
	else:
		self.velocity.x = move_toward(velocity.x, 0, SPEED)
		self.velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()


func shoot() -> void:
	var facing_dir: Vector3 = -camera_3d.global_transform.basis.z
	var force: float = 100.0
	var pos: Vector3 = self.global_position
	
	Global.shoot_ball.rpc_id(1, pos, facing_dir, force)


func _basis_from_normal(normal: Vector3) -> Basis:
	var result: Basis = Basis()
	
	result.x = normal.cross(self.transform.basis.z)
	result.y = normal
	result.z = self.transform.basis.z.cross(normal)
	
	result = result.orthonormalized()
	
	return result


@rpc("any_peer", "call_local")
func register_hit() -> void:
	hud.hit_marker.show()
	await get_tree().create_timer(0.2).timeout
	hud.hit_marker.hide()


func _on_area_3d_grab_body_entered(body: Node3D) -> void:
	if not body.is_in_group('Pickup') or not self.is_multiplayer_authority():
		return
	
	print('athaoentuhasnoetuh')
