class_name VoxelGrid extends Resource

var data: PackedFloat32Array
var resolution: int

func _init(resolution: int):
	self.resolution = resolution
	self.data.resize(resolution * resolution * resolution)
	self.data.fill(1.0)

func read(x: int, y: int, z: int):
	#allows to index every element
	#used bacause gdscript doesn't allow for arr[x][y][z] indexing
	return self.data[x + self.resolution * (y + self.resolution * z)]

func write(x: int, y: int, z: int, value: float):
	self.data[x + self.resolution * (y + self.resolution * z)] = value
