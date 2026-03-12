extends Node3D


const TARGET: PackedScene = preload("uid://bad2sr8q4w27s")


@onready var spawn_container: Node3D = %SpawnContainer
@onready var timer_target: Timer = %TimerTarget


func _ready() -> void:
	Global.forest = self
	Global.spawn_container = spawn_container
	timer_target.timeout.connect(spawn_target)


func spawn_target() -> void:
	if is_multiplayer_authority() and get_tree().get_node_count_in_group('Target') < 10:
		var new_target: StaticBody3D = TARGET.instantiate()
		new_target.position = Vector3(randf_range(-25.0, 25.0), 1.0, randf_range(-25.0, 25.0))
		spawn_container.add_child(new_target, true)
