extends CanvasLayer


const WORLD_FOREST: PackedScene = preload("uid://ef4g23lco1jq")


@onready var enet_menu: VBoxContainer = %EnetMenu

@onready var button_join: Button = %ButtonJoin
@onready var button_quit: Button = %ButtonQuit

@onready var tube_menu: VBoxContainer = %TubeMenu

@onready var line_edit_session_id: LineEdit = %LineEditSessionID
@onready var line_edit_username: LineEdit = %LineEditUsername
@onready var button_join_tube: Button = %ButtonJoinTube
@onready var button_quit_tube: Button = %ButtonQuitTube
@onready var button_create_tube: Button = %ButtonCreateTube


func _ready() -> void:
	if Network.tube_enabled:
		enet_menu.hide()
	else:
		tube_menu.hide()
	
	button_join.pressed.connect(on_join)
	button_quit.pressed.connect(func() -> void: get_tree().quit())
	
	line_edit_session_id.text_changed.connect(update_session)
	line_edit_username.text_changed.connect(update_username)
	button_join_tube.disabled = true
	button_join_tube.pressed.connect(on_join_tube)
	button_quit_tube.pressed.connect(func() -> void: get_tree().quit())
	button_create_tube.pressed.connect(on_create_tube)
	
	Network.tube_client.error_raised.connect(on_error_raised)
	
	if OS.has_feature('server'):
		Network.start_server()
		await get_tree().create_timer(0.1).timeout
		add_world()


func on_join() -> void:
	Network.join_server()
	add_world()


func add_world() -> void:
	var new_world: Node3D = WORLD_FOREST.instantiate()
	get_tree().current_scene.add_child(new_world)
	self.hide()


func on_join_tube() -> void:
	Network.tube_join(line_edit_session_id.text)
	multiplayer.connected_to_server.connect(add_world)


func on_create_tube() -> void:
	Network.tube_create()
	add_world()


func update_session(new_text: String) -> void:
	if new_text != '':
		button_join_tube.disabled = false
	else:
		button_join_tube.disabled = true


func update_username(new_text: String) -> void:
	Global.username = new_text


func on_error_raised(_code: int, _message: String) -> void:
	line_edit_session_id.text = ''
	button_join_tube.add_theme_color_override('font_disabled_color', Color.DARK_RED)
	button_join_tube.disabled = true
	Network.clean_up_signals()
