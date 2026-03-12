extends Node3D


var look_sensitivity: float = 0.001


@onready var camera_3d: Camera3D = $Camera3D
@onready var root_node: Node3D = $"../.."


func _unhandled_input(event: InputEvent) -> void:
	if not self.is_multiplayer_authority():
		return
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			root_node.rotate_y(-event.relative.x * look_sensitivity)
			self.rotate_x(-event.relative.y * look_sensitivity)
			self.rotation.x = clamp(self.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		
		if event.is_action_pressed("zoom_out"):
			camera_3d.position.z += 0.1
		
		if event.is_action_pressed("zoom_in"):
			camera_3d.position.z -= 0.1
