class_name VoxelGrid extends Node3D

var data: PackedFloat32Array
var resolution: int = 10
@onready var borders_mesh = $borders_mesh

func _init():
	self.data.resize(resolution * resolution * resolution)
	self.data.fill(1.0)
	print("vertex count: ", self.data.size())
	

#uses both _init and _ready, because else either self.data or borders_mesh
#don't load in time
func _ready():
	borders_mesh.gen_grid_borders_mesh()
	

func read(x: int, y: int, z: int):
	#allows to index every element
	#used bacause gdscript doesn't allow for arr[x][y][z] indexing
	return self.data[x + self.resolution * (y + self.resolution * z)]

func write(x: int, y: int, z: int, value: float):
	self.data[x + self.resolution * (y + self.resolution * z)] = value
