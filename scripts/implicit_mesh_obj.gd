class_name ImplicidSurface extends Node3D

@export var voxel_grid: VoxelGrid
@onready var control = $Control

func _ready():
	$Control/VBoxContainer/HBPosX/VBoxContainer/slider_pos_x.value = position.x
	$Control/VBoxContainer/HBPosY/VBoxContainer/slider_pos_y.value = position.y
	$Control/VBoxContainer/HBPosZ/VBoxContainer/slider_pos_z.value = position.z


func hide_ui():
	control.hide()

func show_ui():
	control.show()
