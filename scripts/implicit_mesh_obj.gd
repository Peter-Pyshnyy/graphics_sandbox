class_name ImplicidSurface extends Node3D

@export var voxel_grid: VoxelGrid
@onready var control = $Control

func hide_ui():
	control.hide()

func show_ui():
	control.show()
