extends MeshInstance3D
class_name cube

var cube_scene: PackedScene = ResourceLoader.load("res://src/environment/cubes/cubes.tscn") 
@export var recursion_depth: int = 4


func init(level: int) -> void:
	print("level", level)
	if level == recursion_depth:
		print("max recursion level reached")
		return
	make_child(level, Vector3(1.0, 0.0, 0.0))
	make_child(level, Vector3(0.0, 1.0, 0.0))
	make_child(level, Vector3(-1.0, 0.0, 0.0))
	make_child(level, Vector3(0.0, -1.0, 0.0))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_tree().get_nodes_in_group("cube").size() == 1:
		init(0)
		print("first cube spawned")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func make_child(level: int, dir: Vector3) -> void:
	dir /= pow(2, level) 
	var new_cubes: cube = cube_scene.instantiate()
	add_child(new_cubes)
	new_cubes.global_position = global_position + dir / pow(2, level) 
	new_cubes.scale /= 2.0
	new_cubes.init(level + 1)
	
