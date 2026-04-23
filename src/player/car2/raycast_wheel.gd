extends RayCast3D
class_name Wheel


@export var spring_strength: float = 5000.0
@export var spring_damping: float = 120.0
@export var rest_dist: float = 0.3
@export var over_extend: float = 0.0
@export var wheel_radius: float = 0.3
@export var is_motor: bool = false
@export var grip_curve: Curve


@onready var wheel: MeshInstance3D = self.get_child(0)
