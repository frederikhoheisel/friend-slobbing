#class_name Player
extends CharacterBody3D


const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5


@export var sensitivity: float = 0.002


var immobile: bool = false


@onready var camera_3d: Camera3D = %Camera3D
@onready var head: Node3D = %Head
@onready var nameplate: Label3D = %Nameplate

@onready var menu: Control = %Menu
@onready var button_leave: Button = %ButtonLeave
@onready var label_session: Label = %LabelSession
@onready var button_copy_session: Button = %ButtonCopySession

@onready var canvas_layer: CanvasLayer = %CanvasLayer
@onready var hit_marker: Label = %HitMarker



func _enter_tree() -> void:
	self.set_multiplayer_authority(int(self.name))


func _ready() -> void:
	menu.hide()
	self.add_to_group('Player')
	nameplate.text = self.name
	hit_marker.hide()
	
	if not self.is_multiplayer_authority():
		self.set_process(false)
		self.set_physics_process(false)
		canvas_layer.hide()
		return
	
	if Global.username:
		nameplate.text = Global.username
	
	label_session.text = Network.tube_client.session_id
	camera_3d.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	button_leave.pressed.connect(func() -> void: Network.leave_server())
	button_copy_session.pressed.connect(func() -> void: DisplayServer.clipboard_set(Network.tube_client.session_id))
	DisplayServer.clipboard_set(Network.tube_client.session_id)


func _unhandled_input(event: InputEvent) -> void:
	if not self.is_multiplayer_authority() or immobile:
		return
	
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitivity)
		camera_3d.rotate_x(-event.relative.y * sensitivity)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, -PI / 2.0, PI / 2.0)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('menu'):
		open_menu()
	
	if immobile:
		return
	
	if Input.is_action_just_pressed("shoot"):
		shoot()


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	var direction: Vector3 = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if immobile:
		direction = Vector3.ZERO
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func open_menu() -> void:
	menu.visible = not menu.visible
	
	immobile = not immobile
	
	if menu.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func shoot() -> void:
	var facing_dir: Vector3 = -camera_3d.global_transform.basis.z
	var force: float = 100.0
	var pos: Vector3 = self.global_position
	
	Global.shoot_ball.rpc_id(1, pos, facing_dir, force)
