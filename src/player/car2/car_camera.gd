extends Camera3D


@export var rest_pos: Vector3
@export var smoothing: float = 0.1

var prev_pos: Vector3

@onready var pivot: Node3D = self.get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	self.look_at(pivot.global_position + Vector3.UP * 2.0, pivot.global_transform.basis.y)
	
	var wish_pos: Vector3 = pivot.global_position + pivot.global_transform.basis.orthonormalized() * (rest_pos)
	
	self.global_position = wish_pos * smoothing + prev_pos * (1.0 - smoothing)
	
	prev_pos = self.global_position
