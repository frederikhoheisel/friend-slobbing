extends Node3D


var object: RigidBody3D


func _physics_process(_delta: float) -> void:
	if object:
		print('grabbbbb')
		var dir: Vector3 = object.global_position - self.global_position
		object.apply_central_force(-dir * 10.0)
