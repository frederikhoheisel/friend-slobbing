extends Node


const BALL: PackedScene = preload("uid://dbhr21cpbufgf")


var username: String = ''

var forest: Node3D
var spawn_container: Node3D


@rpc("any_peer", "call_local")
func shoot_ball(pos: Vector3, dir: Vector3, force: float) -> void:
	var new_ball: RigidBody3D = BALL.instantiate()
	new_ball.source = multiplayer.get_remote_sender_id()
	new_ball.position = pos + Vector3(0.0, 1.5, 0.0) + dir * 1.2
	spawn_container.add_child(new_ball, true)
	new_ball.apply_impulse(dir * force)
