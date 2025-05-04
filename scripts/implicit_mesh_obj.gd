class_name ImplicidSurface extends Node3D

@export var voxel_grid: VoxelGrid
@onready var control = $Control
@onready var slider_pos_x: HSlider = $Control/VBoxContainer/HBPosX/VBoxContainer/slider_pos_x
@onready var slider_pos_y: HSlider = $Control/VBoxContainer/HBPosY/VBoxContainer/slider_pos_y
@onready var slider_pos_z: HSlider = $Control/VBoxContainer/HBPosZ/VBoxContainer/slider_pos_z

enum FunctionType {SPHERE, ELLIPSOID, TORUS}
@export var function_type := FunctionType.SPHERE
var function_map := {
	FunctionType.SPHERE: _sphere,
	FunctionType.ELLIPSOID: _ellipsoid,
	FunctionType.TORUS: _torus, 
}

func _ready():
	slider_pos_x.value = position.x
	slider_pos_y.value = position.y
	slider_pos_z.value = position.z
	slider_pos_x.max_value = voxel_grid.position.x + voxel_grid.resolution
	slider_pos_y.max_value = voxel_grid.position.y + voxel_grid.resolution
	slider_pos_z.max_value = voxel_grid.position.z + voxel_grid.resolution
	slider_pos_x.min_value = voxel_grid.position.x
	slider_pos_y.min_value = voxel_grid.position.y
	slider_pos_z.min_value = voxel_grid.position.z

func _sphere(x: int, y: int, z: int, r: float):
	return x*x + y*y + z*z - r*r;

#func _heart(x: int, y: int, z: int, r: float):
	#return pow((x*x + y*y + z*z - 1),3) - (1/5*x*x + y*y) * pow(z,3)

func _ellipsoid(x: int, y: int, z: int, r: float):
	return x*x - y*y - z*z + 1

func _torus(x: int, y: int, z: int, r: float):
	return pow((7.0/2.0 - sqrt(x*x + y*y)),2) + z*z - r*r


func evaluate(x: int, y: int, z: int, r: float):
	return function_map[function_type].call(x, y, z, r)

func hide_ui():
	control.hide()

func show_ui():
	control.show()
