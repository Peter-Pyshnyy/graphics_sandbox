class_name ImplicidSurface extends Node3D

@export var voxel_grid: VoxelGrid
@onready var control = $Control
@onready var slider_pos_x: HSlider = $Control/VBoxContainer/HBPosX/VBoxContainer/slider_pos_x
@onready var slider_pos_y: HSlider = $Control/VBoxContainer/HBPosY/VBoxContainer/slider_pos_y
@onready var slider_pos_z: HSlider = $Control/VBoxContainer/HBPosZ/VBoxContainer/slider_pos_z


func _ready():
	slider_pos_x.max_value = voxel_grid.resolution
	slider_pos_y.max_value = voxel_grid.resolution
	slider_pos_z.max_value = voxel_grid.resolution
	slider_pos_x.value = position.x
	slider_pos_y.value = position.y
	slider_pos_z.value = position.z


func hide_ui():
	control.hide()

func show_ui():
	control.show()
