class_name ImplicidSurface extends Node3D

@onready var control = $Control
@onready var slider_pos_x: HSlider = $Control/VBoxContainer/HBPosX/VBoxContainer/slider_pos_x
@onready var slider_pos_y: HSlider = $Control/VBoxContainer/HBPosY/VBoxContainer/slider_pos_y
@onready var slider_pos_z: HSlider = $Control/VBoxContainer/HBPosZ/VBoxContainer/slider_pos_z
@onready var slider_radius = $Control/VBoxContainer/HBRadius/VBoxContainer/slider_radius
@onready var collision_shape = $Area3D/CollisionShape3D
@onready var render_manager = get_tree().root.get_node("MainScene/RenderManager")
@onready var selection_manager = get_tree().root.get_node("MainScene/SelectionManager")


@export var voxel_grid: VoxelGrid
enum FunctionType {SPHERE, ELLIPSOID, TORUS}
@export var function_type := FunctionType.SPHERE
var function_map := {
	FunctionType.SPHERE: _sphere,
	FunctionType.ELLIPSOID: _ellipsoid,
	FunctionType.TORUS: _torus, 
}
var r := 2.0
var iso := 0.0
var mouse_over = false
var is_selecting = false

signal selection_mouse_enter()
signal selection_mouse_exit()

func _ready():
	slider_radius.value = r
	slider_pos_x.value = position.x
	slider_pos_y.value = position.y
	slider_pos_z.value = position.z
	slider_pos_x.max_value = voxel_grid.position.x + voxel_grid.resolution
	slider_pos_y.max_value = voxel_grid.position.y + voxel_grid.resolution
	slider_pos_z.max_value = voxel_grid.position.z + voxel_grid.resolution
	slider_pos_x.min_value = voxel_grid.position.x
	slider_pos_y.min_value = voxel_grid.position.y
	slider_pos_z.min_value = voxel_grid.position.z

func _input(event):
	if event.is_action_pressed("select_surface"):
		is_selecting = true
	if event.is_action_released("select_surface"):
		is_selecting = false
		selection_mouse_exit.emit()

func _process(delta):
	#visual feedback for surface selection
	if is_selecting && mouse_over:
		selection_mouse_enter.emit()
		selection_manager.hover_over = self

func _sphere(x: int, y: int, z: int):
	return pow((position.x - x),2) + pow((position.y - y),2) + pow((position.z - z),2) - r*r;

#func _heart(x: int, y: int, z: int, r: float):
	#return pow((x*x + y*y + z*z - 1),3) - (1/5*x*x + y*y) * pow(z,3)

func _ellipsoid(x: int, y: int, z: int):
	return x*x - y*y - z*z + 1

func _torus(x:int, y:int, z:int):
	return pow((7.0/2.0 - sqrt(pow((position.x - x),2) + pow((position.y - y),2))),2) + pow((position.z - z),2) - r*r

func _on_area_3d_mouse_entered():
	mouse_over = true

func _on_area_3d_mouse_exited():
	mouse_over = false
	selection_mouse_exit.emit()

func _on_slider_iso_value_changed(value):
	iso = value
	render_manager.generate_mesh()

func _on_slider_radius_value_changed(value):
	r = value
	collision_shape.update_scale(value * 2)
	render_manager.generate_mesh()

func _on_slider_pos_x_value_changed(value):
	if value == round(position.x):
		return
	position.x = value
	render_manager.generate_mesh()

func _on_slider_pos_y_value_changed(value):
	if value == round(position.y):
		return
	position.y = value
	render_manager.generate_mesh()

func _on_slider_pos_z_value_changed(value):
	if value == round(position.z):
		return
	position.z = value
	render_manager.generate_mesh()


func evaluate(x: int, y: int, z: int):
	return function_map[function_type].call(x, y, z)

func hide_ui():
	control.hide()

func show_ui():
	control.show()
