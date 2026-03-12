class_name IKTarget
extends Marker3D


@export var parent: CharacterBody3D
@export var debug: bool = false
@export var neighbour: IKTarget
@export var diagonal: IKTarget


var step_length: float = 0.3
var step_duration: float = 0.1
var is_stepping: bool = false
var og_pos: Vector3
var prev_pos: Vector3 = Vector3.ZERO
var tween: Tween


var cur_wish_pos: Vector3

@onready var debug_target: MeshInstance3D = $DebugTarget
@onready var ray_cast_3d: RayCast3D = $RayCast3D


func _ready() -> void:
	og_pos = self.position


func _physics_process(_delta: float) -> void:
	#printt("parent: ", parent.global_position, "self: ", self.global_position)
	
	var pos: Vector3 = self.global_position
	var parent_transform: Transform3D = parent.global_transform
	
	cur_wish_pos = (parent_transform * Transform3D(Basis.IDENTITY, og_pos)).origin + parent.velocity.normalized() * 0.2
	
	debug_target.global_position = cur_wish_pos
	#debug_print(["cur_wish_pos: ", cur_wish_pos, "parent.global_position: ", parent.global_position])
	
	var dir: Vector3 = pos - cur_wish_pos
	dir.y = 0.0
	
	if dir.length() > step_length:
		step()


func step() -> void:
	if neighbour.is_stepping or is_stepping:
		return
	
	var target_pos: Vector3 = get_target_pos()
	var target_pos_half: Vector3 = (target_pos + cur_wish_pos) * 0.5
	
	
	is_stepping = true
	
	diagonal.step()
	
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.set_parallel(false)
	
	tween.tween_property(self, "global_position", target_pos_half + owner.basis.y * 0.1, step_duration / 2.0)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "global_position", target_pos, step_duration / 2.0)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	tween.tween_callback(func() -> void: is_stepping = false)


func get_target_pos() -> Vector3:
	var target_pos: Vector3 = cur_wish_pos + parent.velocity.normalized() * step_length
	ray_cast_3d.global_position = target_pos + Vector3(0.0, 0.5, 0.0)
	ray_cast_3d.force_raycast_update()
	
	#if ray_cast_3d.is_colliding():
	return ray_cast_3d.get_collision_point()
	#else:
	#	return cur_wish_pos


func debug_print(...args: Array) -> void:
	if debug:
		printt.callv(args)
