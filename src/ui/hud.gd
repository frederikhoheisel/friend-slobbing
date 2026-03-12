extends CanvasLayer


@onready var menu: Control = %Menu
@onready var button_leave: Button = %ButtonLeave
@onready var label_session: Label = %LabelSession
@onready var button_copy_session: Button = %ButtonCopySession

@onready var hit_marker: Label = %HitMarker
@onready var hud: CanvasLayer = %HUD


func _ready() -> void:
	hit_marker.hide()
	
	if not self.is_multiplayer_authority():
		self.set_process(false)
		self.set_physics_process(false)
		return
	
	label_session.text = Network.tube_client.session_id
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	button_leave.pressed.connect(func() -> void: Network.leave_server())
	button_copy_session.pressed.connect(func() -> void: DisplayServer.clipboard_set(Network.tube_client.session_id))
	DisplayServer.clipboard_set(Network.tube_client.session_id)


#func _process(_delta: float) -> void:
	#if Input.is_action_just_pressed('menu'):
		#open_menu()


func open_menu() -> void:
	menu.visible = not menu.visible
	
	if menu.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
