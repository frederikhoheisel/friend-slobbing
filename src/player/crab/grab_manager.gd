extends Node3D


var object: RigidBody3D
var target: RigidBody3D


@onready var ik_target_arm_left: Marker3D = %IKTargetArmLeft
@onready var ik_target_arm_right: Marker3D = %IKTargetArmRight


func _physics_process(_delta: float) -> void:
	if object:
		var dir: Vector3 = object.global_position - self.global_position
		object.apply_central_force(-dir.normalized() * 10.0)
		
		ik_target_arm_left.global_position = object.global_position
		ik_target_arm_right.global_position = object.global_position
		
		if dir.length() > 1.0:
			reset_target()


func _unhandled_input(event: InputEvent) -> void:
	if not self.is_multiplayer_authority():
		return
	
	if event.is_action_pressed("grab"):
		if target:
			object = target
	
	if event.is_action_released("grab"):
		reset_target()


func reset_target() -> void:
	object = null
	ik_target_arm_left.position = Vector3(-0.16, 0.2, -0.26)
	ik_target_arm_right.position = Vector3(0.16, 0.2, -0.26)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Pickup"):
		target = body


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Pickup"):
		target = null
