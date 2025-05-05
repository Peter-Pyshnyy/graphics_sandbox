extends CollisionShape3D
@onready var r = $"../..".voxel_grid.resolution / 2

func _ready():
	scale = Vector3(r, r, r)

func update_scale(radius):
	r = radius
	scale = Vector3(r, r, r)
