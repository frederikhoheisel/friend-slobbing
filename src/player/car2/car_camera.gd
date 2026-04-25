extends Camera3D


@export var rest_pos: Vector3
@export var smoothing: float = 0.1

var prev_pos: Vector3

@onready var pivot: Node3D = self.get_parent()
@onready var target: Node3D = self.get_parent().get_parent()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		self.top_level = false
		pivot.rotate_y(-event.relative.x * 0.001)
		self.top_level = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	self.look_at(target.global_position + Vector3.UP * 2.0, target.global_transform.basis.y)
	
	var wish_pos: Vector3 = target.global_position + target.global_transform.basis.orthonormalized() * rest_pos
	
	self.global_position = wish_pos * smoothing + prev_pos * (1.0 - smoothing)
	
	prev_pos = self.global_position
